
<cfsetting requestTimeOut = "1000">

<cfparam name="url.year" default="#year(now())#">
<cfquery name="qGetCompanyInformation" datasource="#Application.dsn#">
    SELECT companyName, address, address2, city, state, zipCode
    FROM companies WHERE CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="varchar">
</cfquery>

<cfquery name="qGetSystemConfig" datasource="#Application.dsn#">
    SELECT CASE ISNULL(TIN,'') WHEN '' THEN 'N/A' ELSE TIN END AS TIN FROM systemconfig
     WHERE CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="varchar">
</cfquery>

<cfset companyInfo = qGetCompanyInformation.companyName&Chr(10)&qGetCompanyInformation.address>
<cfif len(trim(qGetCompanyInformation.address2))>
    <cfset companyInfo = companyInfo&Chr(10)&qGetCompanyInformation.address2>
</cfif>
<cfset companyInfo = companyInfo&Chr(10)&qGetCompanyInformation.city&','&qGetCompanyInformation.state&' '&qGetCompanyInformation.zipCode>

<cfquery name="qForm1099" datasource="#Application.dsn#">
    SELECT * FROM vwCarrier1099Export WHERE Year = '#url.year#'
    AND CompanyID = <cfqueryparam value="#url.CompanyID#" cfsqltype="varchar">
</cfquery>
<cfif qForm1099.recordcount>
    <!--- <cfdocument format="pdf"> --->
        <cfoutput>
            <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
            <HTML>
            <HEAD>
                <META http-equiv="Content-Type" content="text/html; charset=UTF-8">
                <META http-equiv="X-UA-Compatible" content="IE=8">
                <TITLE>Load Manager TMS</TITLE>
                <STYLE type="text/css">
                    body {margin-top: 0px;margin-left: 0px;}
                    ##page_1 {position:relative; overflow: hidden;margin: 72px 0px 553px 96px;padding: 0px;border: none;width: 720px;}
                    ##page_2 {position:relative; overflow: hidden;margin: 29px 0px 545px 67px;padding: 0px;border: none;width: 749px;}
                    ##page_2 ##p2dimg1 {position:absolute;top:4px;left:182px;z-index:-1;width:519px;height:431px;}
                    ##page_2 ##p2dimg1 ##p2img1 {width:519px;height:435px;}
                    ##page_3 {position:relative; overflow: hidden;margin: 29px 0px 559px 67px;padding: 0px;border: none;width: 701px;}
                    ##page_3 ##p3dimg1 {position:absolute;top:4px;left:182px;z-index:-1;width:519px;height:431px;}
                    ##page_3 ##p3dimg1 ##p3img1 {width:519px;height:435px;}
                    ##page_4 {position:relative; overflow: hidden;margin: 31px 0px 559px 67px;padding: 0px;border: none;width: 749px;}
                    ##page_4 ##p4dimg1 {position:absolute;top:15px;left:236px;z-index:-1;width:465px;height:418px;}
                    ##page_4 ##p4dimg1 ##p4img1 {width:465px;height:437px;}
                    ##page_4 ##p4inl_img1 {position:relative;width:14px;height:14px;}
                    ##page_4 ##p4inl_img2 {position:relative;width:1px;height:14px;}
                    ##page_5 {position:relative; overflow: hidden;margin: 45px 0px 568px 67px;padding: 0px;border: none;width: 749px;}
                    ##page_5 ##id5_1 {float:left;border:none;margin: 0px 0px 0px 0px;padding: 0px;border:none;width: 365px;overflow: hidden;}
                    ##page_5 ##id5_2 {float:left;border:none;margin: 20px 0px 0px 0px;padding: 0px;border:none;width: 384px;overflow: hidden;}
                    ##page_6 {position:relative; overflow: hidden;margin: 31px 0px 559px 67px;padding: 0px;border: none;width: 749px;}
                    ##page_6 ##p6dimg1 {position:absolute;top:15px;left:236px;z-index:-1;width:465px;height:418px;}
                    ##page_6 ##p6dimg1 ##p6img1 {width:465px;height:425px;}
                    ##page_6 ##p6inl_img1 {position:relative;width:14px;height:14px;}
                    ##page_6 ##p6inl_img2 {position:relative;width:1px;height:14px;}
                    ##page_7 {position:relative; overflow: hidden;margin: 29px 0px 559px 67px;padding: 0px;border: none;width: 701px;}
                    ##page_7 ##p7dimg1 {position:absolute;top:4px;left:182px;z-index:-1;width:519px;height:431px;}
                    ##page_7 ##p7dimg1 ##p7img1 {width:519px;height:431px;}
                    ##page_8 {position:relative; overflow: hidden;margin: 42px 0px 734px 67px;padding: 0px;border: none;width: 700px;}
                    ##page_8 ##id8_1 {float:left;border:none;margin: 0px 0px 0px 0px;padding: 0px;border:none;width: 365px;overflow: hidden;}
                    ##page_8 ##id8_2 {float:left;border:none;margin: 26px 0px 0px 0px;padding: 0px;border:none;width: 335px;overflow: hidden;}
                    .ft0{font: bold 21px 'Arial';color: ##ff0000;line-height: 24px;}
                    .ft1{font: bold 15px 'Arial';line-height: 20px;}
                    .ft2{font: 15px 'Arial';text-decoration: underline;color: ##0000ff;line-height: 19px;}
                    .ft3{font: 15px 'Arial';line-height: 19px;}
                    .ft4{font: 15px 'Arial';line-height: 20px;}
                    .ft5{font: 15px 'Arial';text-decoration: underline;color: ##0000ff;line-height: 20px;}
                    .ft6{font: 15px 'Arial';color: ##0000ff;line-height: 20px;}
                    .ft7{font: 13px 'Times New Roman';line-height: 15px;}
                    .ft8{font: 1px 'Arial';line-height: 1px;}
                    .ft9{font: 13px 'Arial';color: ##ff0000;line-height: 16px;}
                    .ft10{font: 8px 'Arial';color: ##ff0000;line-height: 10px;}
                    .ft11{font: bold 9px 'Arial';color: ##ff0000;line-height: 11px;}
                    .ft12{font: 9px 'Arial';color: ##ff0000;line-height: 12px;}
                    .ft13{font: 9px 'Arial';color: ##ff0000;line-height: 11px;}
                    .ft14{font: 1px 'Arial';line-height: 11px;}
                    .ft15{font: bold 27px 'Arial';color: ##ff0000;line-height: 32px;}
                    .ft16{font: 27px 'Arial';color: ##ff0000;line-height: 32px;}
                    .ft17{font: bold 15px 'Arial';color: ##ff0000;line-height: 18px;}
                    .ft18{font: bold 16px 'Arial';color: ##ff0000;line-height: 17px;}
                    .ft19{font: bold 11px 'Arial';color: ##ff0000;line-height: 14px;}
                    .ft20{font: bold 13px 'Arial';color: ##ff0000;line-height: 14px;}
                    .ft21{font: bold 12px 'Arial';color: ##ff0000;line-height: 15px;}
                    .ft22{font: bold 8px 'Arial';color: ##ff0000;line-height: 10px;}
                    .ft23{font: bold 12px 'Arial';color: ##ff0000;line-height: 12px;}
                    .ft24{font: 1px 'Arial';line-height: 3px;}
                    .ft25{font: bold 12px 'Arial';color: ##ff0000;line-height: 14px;}
                    .ft26{font: bold 10px 'Arial';color: ##ff0000;line-height: 12px;}
                    .ft27{font: 13px 'Arial';color: ##ff0000;line-height: 14px;}
                    .ft28{font: 1px 'Arial';line-height: 5px;}
                    .ft29{font: 13px 'Arial';color: ##ff0000;line-height: 11px;}
                    .ft30{font: 1px 'Arial';line-height: 4px;}
                    .ft31{font: bold 13px 'Arial';color: ##ff0000;line-height: 15px;}
                    .ft32{font: 1px 'Arial';line-height: 6px;}
                    .ft33{font: 9px 'Arial';color: ##ff0000;line-height: 10px;}
                    .ft34{font: 1px 'Arial';line-height: 7px;}
                    .ft35{font: bold 7px 'MS PGothic';color: ##ff0000;line-height: 7px;}
                    .ft36{font: bold 13px 'Arial';color: ##ff0000;line-height: 16px;}
                    .ft37{font: 1px 'Arial';line-height: 9px;}
                    .ft38{font: 1px 'Arial';line-height: 10px;}
                    .ft39{font: 1px 'Arial';line-height: 8px;}
                    .ft40{font: 9px 'Arial';color: ##ff0000;line-height: 8px;}
                    .ft41{font: bold 13px 'Arial';color: ##ff0000;line-height: 13px;}
                    .ft42{font: 15px 'Arial';color: ##ff0000;line-height: 17px;}
                    .ft43{font: 13px 'Arial';line-height: 16px;}
                    .ft44{font: 8px 'Arial';line-height: 10px;}
                    .ft45{font: bold 9px 'Arial';line-height: 11px;}
                    .ft46{font: 9px 'Arial';line-height: 12px;}
                    .ft47{font: 9px 'Arial';line-height: 11px;}
                    .ft48{font: bold 27px 'Arial';line-height: 32px;}
                    .ft49{font: 27px 'Arial';line-height: 32px;}
                    .ft50{font: bold 16px 'Arial';line-height: 19px;}
                    .ft51{font: bold 16px 'Arial';line-height: 17px;}
                    .ft52{font: bold 11px 'Arial';line-height: 14px;}
                    .ft53{font: bold 13px 'Arial';line-height: 16px;}
                    .ft54{font: bold 12px 'Arial';line-height: 15px;}
                    .ft55{font: bold 12px 'Arial';line-height: 14px;}
                    .ft55_1{font: bold 10px 'Arial';line-height: 14px;}
                    .ft56{font: bold 7px 'MS PGothic';line-height: 7px;}
                    .ft57{font: bold 8px 'Arial';line-height: 10px;}
                    .ft58{font: bold 13px 'Arial';line-height: 13px;}
                    .ft59{font: 11px 'Arial';line-height: 14px;}
                    .ft60{font: 9px 'Arial';line-height: 10px;}
                    .ft61{font: 11px 'Arial';line-height: 12px;}
                    .ft62{font: 13px 'Arial';line-height: 14px;}
                    .ft63{font: 11px 'Arial';line-height: 10px;}
                    .ft64{font: 11px 'Arial';line-height: 13px;}
                    .ft65{font: 11px 'Arial';line-height: 11px;}
                    .ft66{font: bold 8px 'Arial';line-height: 11px;}
                    .ft67{font: 8px 'Arial';line-height: 11px;}
                    .ft68{font: italic 9px 'Arial';line-height: 12px;}
                    .ft69{font: bold 12px 'Arial';line-height: 13px;}
                    .ft70{font: bold 13px 'Arial';line-height: 14px;}
                    .ft71{font: 13px 'Arial';line-height: 15px;}
                    .ft72{font: 13px 'Arial';line-height: 13px;}
                    .ft73{font: 9px 'Arial';line-height: 9px;}
                    .ft74{font: bold 13px 'Arial';line-height: 15px;}
                    .ft75{font: bold 24px 'Arial';line-height: 29px;}
                    .ft76{font: 13px 'Arial';margin-left: 3px;line-height: 15px;}
                    .ft77{font: 13px 'Arial';margin-left: 4px;line-height: 16px;}
                    .ft78{font: italic 13px 'Arial';line-height: 15px;}
                    .p0{text-align: left;padding-left: 262px;margin-top: 0px;margin-bottom: 0px;}
                    .p1{text-align: left;padding-right: 103px;margin-top: 13px;margin-bottom: 0px;}
                    .p2{text-align: left;padding-right: 118px;margin-top: 24px;margin-bottom: 0px;}
                    .p3{text-align: left;padding-right: 108px;margin-top: 5px;margin-bottom: 0px;}
                    .p4{text-align: left;padding-right: 103px;margin-top: 4px;margin-bottom: 0px;}
                    .p5{text-align: left;padding-right: 117px;margin-top: 6px;margin-bottom: 0px;}
                    .p6{text-align: right;padding-right: 19px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p7{text-align: left;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p8{text-align: left;padding-left: 38px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p9{text-align: left;padding-left: 5px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p10{text-align: left;padding-left: 6px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p11{text-align: left;padding-left: 8px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p12{text-align: center;padding-right: 1px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p13{text-align: right;padding-right: 6px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p14{text-align: left;padding-left: 48px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p15{text-align: left;padding-left: 7px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p16{text-align: right;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p17{text-align: left;padding-left: 14px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p18{text-align: left;padding-left: 20px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p19{text-align: left;padding-left: 15px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p20{text-align: left;padding-left: 2px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p21{text-align: left;padding-left: 3px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p22{text-align: left;padding-left: 16px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p23{text-align: right;padding-right: 35px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p24{text-align: right;padding-right: 92px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p25{text-align: left;padding-left: 1px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p26{text-align: left;padding-left: 31px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p27{text-align: left;margin-top: 0px;margin-bottom: 0px;}
                    .p28{text-align: right;padding-right: 1px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p29{text-align: center;padding-right: 13px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p30{text-align: left;padding-left: 4px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p31{text-align: left;padding-left: 11px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p32{text-align: left;padding-left: 259px;margin-top: 0px;margin-bottom: 0px;}
                    .p33{text-align: right;padding-right: 13px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p34{text-align: right;padding-right: 123px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p35{text-align: left;padding-left: 47px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p36{text-align: center;padding-right: 3px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p37{text-align: left;padding-left: 58px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p38{text-align: right;padding-right: 84px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p39{text-align: left;padding-left: 12px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p40{text-align: left;padding-left: 21px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p41{text-align: left;padding-left: 13px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p42{text-align: left;padding-right: 32px;margin-top: 0px;margin-bottom: 0px;}
                    .p43{text-align: left;padding-right: 37px;margin-top: 0px;margin-bottom: 0px;}
                    .p44{text-align: justify;padding-right: 32px;margin-top: 2px;margin-bottom: 0px;}
                    .p45{text-align: left;padding-right: 27px;margin-top: 1px;margin-bottom: 0px;}
                    .p46{text-align: left;padding-right: 33px;margin-top: 0px;margin-bottom: 0px;}
                    .p47{text-align: justify;padding-right: 27px;margin-top: 1px;margin-bottom: 0px;}
                    .p48{text-align: left;padding-right: 32px;margin-top: 12px;margin-bottom: 0px;}
                    .p49{text-align: left;padding-right: 45px;margin-top: 4px;margin-bottom: 0px;}
                    .p50{text-align: left;margin-top: 3px;margin-bottom: 0px;}
                    .p51{text-align: left;padding-right: 49px;margin-top: 0px;margin-bottom: 0px;}
                    .p52{text-align: left;padding-right: 50px;margin-top: 27px;margin-bottom: 0px;}
                    .p53{text-align: left;padding-right: 48px;margin-top: 0px;margin-bottom: 0px;}
                    .p54{text-align: left;margin-top: 4px;margin-bottom: 0px;}
                    .p55{text-align: left;padding-right: 66px;margin-top: 0px;margin-bottom: 0px;}
                    .p56{text-align: left;padding-right: 56px;margin-top: 1px;margin-bottom: 0px;}
                    .p57{text-align: justify;padding-right: 62px;margin-top: 0px;margin-bottom: 0px;}
                    .p58{text-align: left;padding-right: 51px;margin-top: 0px;margin-bottom: 0px;}
                    .p59{text-align: justify;padding-right: 51px;margin-top: 0px;margin-bottom: 0px;}
                    .p60{text-align: right;padding-right: 121px;margin-top: 0px;margin-bottom: 0px;white-space: nowrap;}
                    .p61{text-align: left;padding-right: 38px;margin-top: 0px;margin-bottom: 0px;}
                    .p62{text-align: left;margin-top: 2px;margin-bottom: 0px;}
                    .p63{text-align: left;padding-right: 52px;margin-top: 0px;margin-bottom: 0px;text-indent: 13px;}
                    .p64{text-align: left;padding-right: 43px;margin-top: 1px;margin-bottom: 0px;text-indent: 13px;}
                    .p65{text-align: left;padding-right: 30px;margin-top: 0px;margin-bottom: 0px;}
                    .p66{text-align: left;padding-right: 34px;margin-top: 2px;margin-bottom: 0px;}
                    .p67{text-align: left;padding-right: 36px;margin-top: 0px;margin-bottom: 0px;text-indent: 13px;}
                    .p68{text-align: left;padding-right: 19px;margin-top: 4px;margin-bottom: 0px;}
                    .p69{text-align: justify;padding-right: 14px;margin-top: 6px;margin-bottom: 0px;}
                    .td0{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 144px;vertical-align: bottom;}
                    .td1{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 10px;vertical-align: bottom;}
                    .td2{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 110px;vertical-align: bottom;}
                    .td3{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 188px;vertical-align: bottom;}
                    .td4{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 18px;vertical-align: bottom;}
                    .td5{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 78px;vertical-align: bottom;}
                    .td6{padding: 0px;margin: 0px;width: 18px;vertical-align: bottom;}
                    .td7{padding: 0px;margin: 0px;width: 20px;vertical-align: bottom;}
                    .td8{padding: 0px;margin: 0px;width: 105px;vertical-align: bottom;}
                    .td9{border-left: ##ff0000 1px solid;border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 325px;vertical-align: bottom;}
                    .td10{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 134px;vertical-align: bottom;}
                    .td11{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 95px;vertical-align: bottom;}
                    .td12{border-left: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 273px;vertical-align: bottom;}
                    .td13{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 52px;vertical-align: bottom;}
                    .td14{padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;}
                    .td15{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;}
                    .td16{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 77px;vertical-align: bottom;}
                    .td17{border-left: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 143px;vertical-align: bottom;}
                    .td18{padding: 0px;margin: 0px;width: 10px;vertical-align: bottom;}
                    .td19{padding: 0px;margin: 0px;width: 48px;vertical-align: bottom;}
                    .td20{padding: 0px;margin: 0px;width: 58px;vertical-align: bottom;}
                    .td21{padding: 0px;margin: 0px;width: 4px;vertical-align: bottom;}
                    .td22{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;}
                    .td23{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;}
                    .td24{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 95px;vertical-align: bottom;}
                    .td25{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 20px;vertical-align: bottom;}
                    .td26{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 105px;vertical-align: bottom;}
                    .td27{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 133px;vertical-align: bottom;}
                    .td28{border-left: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 143px;vertical-align: bottom;}
                    .td29{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 48px;vertical-align: bottom;}
                    .td30{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 58px;vertical-align: bottom;}
                    .td31{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 4px;vertical-align: bottom;}
                    .td32{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 52px;vertical-align: bottom;}
                    .td33{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;}
                    .td34{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 9px;vertical-align: bottom;}
                    .td35{padding: 0px;margin: 0px;width: 110px;vertical-align: bottom;}
                    .td36{padding: 0px;margin: 0px;width: 78px;vertical-align: bottom;}
                    .td37{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;}
                    .td38{border-left: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 143px;vertical-align: bottom;background: ##ffb3b3;}
                    .td39{padding: 0px;margin: 0px;width: 10px;vertical-align: bottom;background: ##ffb3b3;}
                    .td40{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 9px;vertical-align: bottom;background: ##ffb3b3;}
                    .td41{border-right: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 47px;vertical-align: bottom;background: ##ffb3b3;}
                    .td42{border-right: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 57px;vertical-align: bottom;background: ##ffb3b3;}
                    .td43{padding: 0px;margin: 0px;width: 4px;vertical-align: bottom;background: ##ffb3b3;}
                    .td44{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 52px;vertical-align: bottom;background: ##ffb3b3;}
                    .td45{padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;background: ##ffb3b3;}
                    .td46{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;background: ##ffb3b3;}
                    .td47{padding: 0px;margin: 0px;width: 18px;vertical-align: bottom;background: ##ffb3b3;}
                    .td48{border-right: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 77px;vertical-align: bottom;background: ##ffb3b3;}
                    .td49{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;background: ##ffb3b3;}
                    .td50{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 9px;vertical-align: bottom;}
                    .td51{padding: 0px;margin: 0px;width: 114px;vertical-align: bottom;}
                    .td52{border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;background: ##ffb3b3;}
                    .td53{border-right: ##ff0000 1px solid;border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;background: ##ffb3b3;}
                    .td54{border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 18px;vertical-align: bottom;background: ##ffb3b3;}
                    .td55{border-right: ##ffb3b3 1px solid;border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 77px;vertical-align: bottom;background: ##ffb3b3;}
                    .td56{border-right: ##ff0000 1px solid;border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;background: ##ffb3b3;}
                    .td57{border-left: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 163px;vertical-align: bottom;}
                    .td58{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 134px;vertical-align: bottom;}
                    .td59{border-left: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 163px;vertical-align: bottom;}
                    .td60{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;background: ##ffb3b3;}
                    .td61{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;background: ##ffb3b3;}
                    .td62{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 18px;vertical-align: bottom;background: ##ffb3b3;}
                    .td63{border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 96px;vertical-align: bottom;background: ##ffb3b3;}
                    .td64{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 19px;vertical-align: bottom;background: ##ffb3b3;}
                    .td65{border-left: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 153px;vertical-align: bottom;}
                    .td66{border-right: ##ffb3b3 1px solid;border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 9px;vertical-align: bottom;background: ##ffb3b3;}
                    .td67{border-right: ##ff0000 1px solid;border-bottom: ##ffb3b3 1px solid;padding: 0px;margin: 0px;width: 47px;vertical-align: bottom;background: ##ffb3b3;}
                    .td68{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 57px;vertical-align: bottom;}
                    .td69{border-right: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 47px;vertical-align: bottom;}
                    .td70{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 47px;vertical-align: bottom;}
                    .td71{border-right: ##ff0000 1px solid;border-bottom: ##ff0000 1px solid;padding: 0px;margin: 0px;width: 57px;vertical-align: bottom;}
                    .td72{padding: 0px;margin: 0px;width: 144px;vertical-align: bottom;}
                    .td73{padding: 0px;margin: 0px;width: 130px;vertical-align: bottom;}
                    .td74{padding: 0px;margin: 0px;width: 188px;vertical-align: bottom;}
                    .td75{padding: 0px;margin: 0px;width: 239px;vertical-align: bottom;}
                    .td76{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 164px;vertical-align: bottom;}
                    .td77{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;}
                    .td78{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 183px;vertical-align: bottom;}
                    .td79{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 12px;vertical-align: bottom;}
                    .td80{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 84px;vertical-align: bottom;}
                    .td81{padding: 0px;margin: 0px;width: 33px;vertical-align: bottom;}
                    .td82{padding: 0px;margin: 0px;width: 5px;vertical-align: bottom;}
                    .td83{border-left: ##000000 1px solid;border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 325px;vertical-align: bottom;}
                    .td84{padding: 0px;margin: 0px;width: 14px;vertical-align: bottom;}
                    .td85{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 120px;vertical-align: bottom;}
                    .td86{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 95px;vertical-align: bottom;}
                    .td87{padding: 0px;margin: 0px;width: 12px;vertical-align: bottom;}
                    .td88{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 83px;vertical-align: bottom;}
                    .td89{border-left: ##000000 1px solid;padding: 0px;margin: 0px;width: 278px;vertical-align: bottom;}
                    .td90{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 47px;vertical-align: bottom;}
                    .td91{border-left: ##000000 1px solid;padding: 0px;margin: 0px;width: 163px;vertical-align: bottom;}
                    .td92{padding: 0px;margin: 0px;width: 9px;vertical-align: bottom;}
                    .td93{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 14px;vertical-align: bottom;}
                    .td94{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 120px;vertical-align: bottom;}
                    .td95{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 95px;vertical-align: bottom;}
                    .td96{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 33px;vertical-align: bottom;}
                    .td97{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 5px;vertical-align: bottom;}
                    .td98{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 105px;vertical-align: bottom;}
                    .td99{padding: 0px;margin: 0px;width: 117px;vertical-align: bottom;}
                    .td100{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 4px;vertical-align: bottom;}
                    .td101{border-left: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 163px;vertical-align: bottom;}
                    .td102{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 48px;vertical-align: bottom;}
                    .td103{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 58px;vertical-align: bottom;}
                    .td104{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 9px;vertical-align: bottom;}
                    .td105{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 47px;vertical-align: bottom;}
                    .td106{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 4px;vertical-align: bottom;}
                    .td107{border-left: ##000000 1px solid;border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 162px;vertical-align: bottom;}
                    .td108{padding: 0px;margin: 0px;width: 115px;vertical-align: bottom;}
                    .td109{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 121px;vertical-align: bottom;}
                    .td110{padding: 0px;margin: 0px;width: 84px;vertical-align: bottom;}
                    .td111{border-left: ##000000 1px solid;border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 162px;vertical-align: bottom;}
                    .td112{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 67px;vertical-align: bottom;}
                    .td113{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 117px;vertical-align: bottom;}
                    .td114{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 57px;vertical-align: bottom;}
                    .td115{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 57px;vertical-align: bottom;}
                    .td116{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 134px;vertical-align: bottom;}
                    .td117{padding: 0px;margin: 0px;width: 129px;vertical-align: bottom;}
                    .td118{padding: 0px;margin: 0px;width: 164px;vertical-align: bottom;}
                    .td119{padding: 0px;margin: 0px;width: 250px;vertical-align: bottom;}
                    .td120{padding: 0px;margin: 0px;width: 227px;vertical-align: bottom;}
                    .td121{border-left: ##000000 1px solid;border-right: ##000000 1px solid;border-top: ##000000 1px solid;padding: 0px;margin: 0px;width: 325px;vertical-align: bottom;}
                    .td122{border-right: ##000000 1px solid;border-top: ##000000 1px solid;padding: 0px;margin: 0px;width: 136px;vertical-align: bottom;}
                    .td123{border-right: ##000000 1px solid;border-top: ##000000 1px solid;padding: 0px;margin: 0px;width: 93px;vertical-align: bottom;}
                    .td124{padding: 0px;margin: 0px;width: 6px;vertical-align: bottom;}
                    .td125{padding: 0px;margin: 0px;width: 104px;vertical-align: bottom;}
                    .td126{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 136px;vertical-align: bottom;}
                    .td127{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 93px;vertical-align: bottom;}
                    .td128{border-left: ##000000 1px solid;padding: 0px;margin: 0px;width: 304px;vertical-align: bottom;}
                    .td129{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 21px;vertical-align: bottom;}
                    .td130{border-left: ##000000 1px solid;padding: 0px;margin: 0px;width: 123px;vertical-align: bottom;}
                    .td131{padding: 0px;margin: 0px;width: 40px;vertical-align: bottom;}
                    .td132{padding: 0px;margin: 0px;width: 35px;vertical-align: bottom;}
                    .td133{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 136px;vertical-align: bottom;}
                    .td134{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 93px;vertical-align: bottom;}
                    .td135{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 6px;vertical-align: bottom;}
                    .td136{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 104px;vertical-align: bottom;}
                    .td137{padding: 0px;margin: 0px;width: 127px;vertical-align: bottom;}
                    .td138{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 5px;vertical-align: bottom;}
                    .td139{border-left: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 123px;vertical-align: bottom;}
                    .td140{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 40px;vertical-align: bottom;}
                    .td141{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 35px;vertical-align: bottom;}
                    .td142{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 21px;vertical-align: bottom;}
                    .td143{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 94px;vertical-align: bottom;}
                    .td144{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 5px;vertical-align: bottom;}
                    .td145{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 39px;vertical-align: bottom;}
                    .td146{padding: 0px;margin: 0px;width: 141px;vertical-align: bottom;}
                    .td147{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 132px;vertical-align: bottom;}
                    .td148{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 39px;vertical-align: bottom;}
                    .td149{padding: 0px;margin: 0px;width: 94px;vertical-align: bottom;}
                    .td150{padding: 0px;margin: 0px;width: 124px;vertical-align: bottom;}
                    .td151{padding: 0px;margin: 0px;width: 181px;vertical-align: bottom;}
                    .td152{padding: 0px;margin: 0px;width: 159px;vertical-align: bottom;}
                    .td153{padding: 0px;margin: 0px;width: 237px;vertical-align: bottom;}
                    .td154{border-top: ##000000 1px solid;padding: 0px;margin: 0px;width: 14px;vertical-align: bottom;}
                    .td155{border-right: ##000000 1px solid;border-top: ##000000 1px solid;padding: 0px;margin: 0px;width: 120px;vertical-align: bottom;}
                    .td156{border-right: ##000000 1px solid;border-top: ##000000 1px solid;padding: 0px;margin: 0px;width: 95px;vertical-align: bottom;}
                    .td157{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 56px;vertical-align: bottom;}
                    .td158{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 56px;vertical-align: bottom;}
                    .td159{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 162px;vertical-align: bottom;}
                    .td160{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 114px;vertical-align: bottom;}
                    .td161{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 110px;vertical-align: bottom;}
                    .td162{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 188px;vertical-align: bottom;}
                    .td163{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 96px;vertical-align: bottom;}
                    .td164{border-left: ##000000 1px solid;padding: 0px;margin: 0px;width: 273px;vertical-align: bottom;}
                    .td165{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 52px;vertical-align: bottom;}
                    .td166{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 134px;vertical-align: bottom;}
                    .td167{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 4px;vertical-align: bottom;}
                    .td168{border-right: ##000000 1px solid;border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 52px;vertical-align: bottom;}
                    .td169{border-right: ##000000 1px solid;padding: 0px;margin: 0px;width: 133px;vertical-align: bottom;}
                    .td170{padding: 0px;margin: 0px;width: 96px;vertical-align: bottom;}
                    .td171{border-bottom: ##000000 1px solid;padding: 0px;margin: 0px;width: 129px;vertical-align: bottom;}
                    .tr0{height: 19px;}
                    .tr1{height: 20px;}
                    .tr2{height: 12px;}
                    .tr3{height: 11px;}
                    .tr4{height: 24px;}
                    .tr5{height: 23px;}
                    .tr6{height: 41px;}
                    .tr7{height: 17px;}
                    .tr8{height: 32px;}
                    .tr9{height: 31px;}
                    .tr10{height: 14px;}
                    .tr11{height: 18px;}
                    .tr12{height: 3px;}
                    .tr13{height: 21px;}
                    .tr14{height: 16px;}
                    .tr15{height: 5px;}
                    .tr16{height: 4px;}
                    .tr17{height: 15px;}
                    .tr18{height: 6px;}
                    .tr19{height: 10px;}
                    .tr20{height: 22px;}
                    .tr21{height: 7px;}
                    .tr22{height: 9px;}
                    .tr23{height: 8px;}
                    .tr24{height: 13px;}
                    .tr25{height: 49px;}
                    .tr26{height: 34px;}
                    .tr27{height: 40px;}
                    .tr28{height: 25px;}
                    .tr29{height: 51px;}
                    .tr30{height: 28px;}
                    .tr31{height: 27px;}
                    .t0{width: 701px;font: 9px 'Arial';color: ##ff0000;}
                    .t1{width: 701px;font: 9px 'Arial';}
                </STYLE>
            </HEAD>
            <BODY>
                <cfloop query="qform1099">
                    <cfif qform1099.currentrow eq 1>
                        <DIV id="page_1">
                            <P class="p0 ft0">Attention:</P>
                            <P class="p1 ft3">Copy A of this form is provided for informational purposes only. Copy A appears in red, similar to the official IRS form. The official printed version of Copy A of this IRS form is scannable, but the online version of it, printed from this website, is not. Do <SPAN class="ft1">not </SPAN>print and file copy A downloaded from this website; a penalty may be imposed for filing with the IRS information return forms that can't be scanned. See part O in the current General Instructions for Certain Information Returns, available at <A href="http://www.irs.gov/form1099"><SPAN class="ft2">www.irs.gov/form1099</SPAN></A>, for more information about penalties.</P>
                            <P class="p2 ft4">Please note that Copy B and other copies of this form, which appear in black, may be downloaded and printed and used to satisfy the requirement to provide the information to the recipient.</P>
                            <P class="p3 ft4">To order official IRS information returns, which include a scannable Copy A for filing with the IRS and all other applicable copies of the form, visit <A href="http://www.irs.gov/orderforms"><SPAN class="ft5">www.IRS.gov/orderforms</SPAN></A>. Click on <SPAN class="ft6">Employer and Information Returns</SPAN>, and we'll mail you the forms you request and their instructions, as well as any publications you may order.</P>
                            <P class="p4 ft4">Information returns may also be filed electronically using the IRS Filing Information Returns Electronically (FIRE) system (visit <A href="http://www.irs.gov/FIRE"><SPAN class="ft5">www.IRS.gov/FIRE</SPAN></A>) or the IRS Affordable Care Act Information Returns (AIR) program (visit www.IRS.gov/AIR).</P>
                            <P class="p5 ft4">See IRS Publications 1141, 1167, and 1179 for more information about printing these tax forms.</P>
                        </DIV>
                        <P style="page-break-before: always"></P>
                    </cfif>
                    <cfif url.copy EQ "CopyA">
                    <DIV id="page_2">
                        <DIV id="p2dimg1">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAGvAgcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD1Xw34b0KfwtpE02i6dJLJZQs7vaoWYlASSSOTT9a0DRrK0tri00iwgnS/s9skVsiMubiMHBAz0JFP0W71LTtC0+xm8O6i0ttbRwuUltipKqAcZl6cU7UbjUNThgtk0K/h/wBLtpGklkt9qqkyOxO2Unop6A1zpQ5LW1t29PI9iU8R9ZcnP3eZ/b0teX9/t5fI6Kiiiug8cKKKKACiiigArD8Q2tve3ehW93bxTwPftujlQOrYt5iMg8dQDW5WTrcdz52lXNtZy3f2W7MkkcTIG2mGVMjeyjq696ifwnRhW1VTTs9fLo+un5h/wi3h7/oA6X/4Bx/4VD4etbeyu9dt7S3iggS/XbHEgRVzbwk4A46kmpv7Xvv+hc1T/v5bf/HqNEjufO1W5ubOW0+1XYkjjlZC20QxJk7GYdUbvUpR5lyr8P8AgG8pVvZTVWV1pvK/XtzP8jWooorU4AooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigDG8URRz6MkM0ayRSXtmro4yrA3MYIIPUU//AIRbw9/0AdL/APAOP/CrGr2Emo6f5EM6wyrNFMjvHvUGORXGVBGQduOo61X+z+If+gppf/gtk/8Aj9ZtLmbav9x206klRjGFTls31kt7dhnheKODRnhhjWOKO9vFREGFUC5kAAA6Ctmqmm2P9n2QgMnmOZJJZH27QXd2dsDnA3McDJwMcnrVuqgrRSMMRNTqykne7CiiiqMQooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACis7WtQuNNso57a2iuHaeKEpJMYwPMcIDkK38TL26Z9MGL7R4h/wCgXpf/AIMpP/jFS5JOxtGhKUVO6SfdpbGtRVTSr7+09Isr/wAvy/tUEc2zdnbuUHGe+M1bpp3V0Zyi4ScZbrT7gooopkhWX4klkg8LavNDI0csdlMyOhwykISCCOhrUqjrVnJqOhahYwsqy3NtJChc4UFlIGcduamd+V2NaDiq0HLa6v8Aeiv/AMI5Y/8APfVP/Brc/wDxymaDGYLnWbYTTyRQXoWPz53lZQYIWI3OScZYnr3p/wBo8Q/9AvS//BlJ/wDGKl0q0uLc3txdiJJ7ycTNHE5dY8RpGAGIBbiMHoOuO2TCS5lZHTOc/ZSVSad7W1T6+S7GjRRRWpwhRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAGH4rure00iB7m4ihQ39phpHCjidGPX0VWP0BPapv+Ep8Pf9B7S/8AwMj/AMa1qKi0r3R0KpSdNQmnpfZrrbuvIyfC3/IoaL/14Qf+i1rWooqoqySM6s/aVJT7tv723+oUUUUzMKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKK5L/hZnhD/AKC//ktL/wDEUf8ACzPCH/QX/wDJaX/4isvb0v5l953f2Zjv+fMv/AX/AJHW0VU0zU7PWdOiv7CbzrWXOx9pXOCQeCAeoNc7/wALM8If9Bf/AMlpf/iKp1IRSbe5lTweIqSlGFNtx3snp69jraK5L/hZnhD/AKC//ktL/wDEV0WmanZ6zp0V/YTeday52PtK5wSDwQD1BojUhJ2i7hWweIoR5qtNxXmmi3RXJf8ACzPCH/QX/wDJaX/4ij/hZnhD/oL/APktL/8AEVPt6X8y+81/szHf8+Zf+Av/ACOtoqppmp2es6dFf2E3nWsudj7SucEg8EA9Qa53/hZnhD/oL/8AktL/APEVTqQik29zKng8RUlKMKbbjvZPT17HW0VyX/CzPCH/AEF//JaX/wCIrotM1Oz1nTor+wm861lzsfaVzgkHggHqDRGpCTtF3Ctg8RQjzVabivNNFuiuS/4WZ4Q/6C//AJLS/wDxFH/CzPCH/QX/APJaX/4ip9vS/mX3mv8AZmO/58y/8Bf+R1tFVNM1Oz1nTor+wm861lzsfaVzgkHggHqDXO/8LM8If9Bf/wAlpf8A4iqdSEUm3uZU8HiKkpRhTbcd7J6evY62iuS/4WZ4Q/6C/wD5LS//ABFH/CzPCH/QX/8AJaX/AOIqfb0v5l95r/ZmO/58y/8AAX/kdbRXJf8ACzPCH/QX/wDJaX/4iui1PU7PRtOlv7+bybWLG99pbGSAOACepFUqkJJtPYyqYPEU5RjOm05bXT19O5borkv+FmeEP+gv/wCS0v8A8RR/wszwh/0F/wDyWl/+Iqfb0v5l95r/AGZjv+fMv/AX/kdbRVTU9Ts9G06W/v5vJtYsb32lsZIA4AJ6kVzv/CzPCH/QX/8AJaX/AOIqpVIRdpOxlRweIrx5qVNyXkmzraK5L/hZnhD/AKC//ktL/wDEV0Wp6nZ6Np0t/fzeTaxY3vtLYyQBwAT1IoVSEk2nsFTB4inKMZ02nLa6evp3LdFcl/wszwh/0F//ACWl/wDiKP8AhZnhD/oL/wDktL/8RU+3pfzL7zX+zMd/z5l/4C/8jraKqanqdno2nS39/N5NrFje+0tjJAHABPUiud/4WZ4Q/wCgv/5LS/8AxFVKpCLtJ2MqODxFePNSpuS8k2dbRXJf8LM8If8AQX/8lpf/AIiui1PU7PRtOlv7+bybWLG99pbGSAOACepFCqQkm09gqYPEU5RjOm05bXT19O5borkv+FmeEP8AoL/+S0v/AMRR/wALM8If9Bf/AMlpf/iKn29L+Zfea/2Zjv8AnzL/AMBf+R1tFcl/wszwh/0F/wDyWl/+Iqa1+Ifha9vILS31TfPPIsca/Z5RuZjgDJXHU0/bU/5l94nluNSu6Mrf4X/kdPRWdrOu6b4fs0u9Uufs8DyCNW2M+WIJxhQT0BrD/wCFmeEP+gv/AOS0v/xFOVWEXaTSIpYLE1o89KnKS7pNnW0VzFr8Q/C17eQWlvqm+eeRY41+zyjczHAGSuOprW1nXdN8P2aXeqXP2eB5BGrbGfLEE4woJ6A0KpBq6egp4PEQmqcqbUnsrO79EaNFcl/wszwh/wBBf/yWl/8AiKmtfiH4WvbyC0t9U3zzyLHGv2eUbmY4AyVx1NL21P8AmX3mjy3GpXdGVv8AC/8AI6eis7Wdd03w/Zpd6pc/Z4HkEatsZ8sQTjCgnoDWH/wszwh/0F//ACWl/wDiKcqsIu0mkRSwWJrR56VOUl3SbOtormLX4h+Fr28gtLfVN888ixxr9nlG5mOAMlcdTWtrOu6b4fs0u9Uufs8DyCNW2M+WIJxhQT0BoVSDV09BTweIhNU5U2pPZWd36I0aK5L/AIWZ4Q/6C/8A5LS//EUVPt6X8y+81/szHf8APmX/AIC/8j//2Q==" id="p2img1">
                        </DIV>
                        <TABLE cellpadding=0 cellspacing=0 class="t0">
                            <TR>
                                <TD class="tr0 td0"><P class="p6 ft7">9595</P></TD>
                                <TD class="tr0 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr0 td2"><P class="p8 ft9">VOID</P></TD>
                                <TD colspan=3 class="tr0 td3"><P class="p9 ft9">CORRECTED</P></TD>
                                <TD class="tr0 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td5"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td7"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=7 class="tr2 td9"><P class="p10 ft10">PAYER'S name, street address, city or town, state or province, country, ZIP</P></TD>
                                <TD colspan=2 class="tr2 td10"><P class="p11 ft12"><SPAN class="ft11">1 </SPAN>Rents</P></TD>
                                <TD colspan=2 class="tr2 td11"><P class="p12 ft12">OMB No. <NOBR>1545-0115</NOBR></P></TD>
                                <TD class="tr2 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td7"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=6 class="tr3 td12"><P class="p10 ft13">or foreign postal code, and telephone no.</P></TD>
                                <TD class="tr3 td13"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td14"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td15"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td6"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td16"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td6"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td7"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr4 td17" colspan=6><P class="p10 ft26">#qGetCompanyInformation.companyName#</P></TD>
                                <TD class="tr4 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr5 td22"><P class="p13 ft9">$</P></TD>
                                <TD class="tr5 td23"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 rowspan=2 class="tr6 td11"><P class="p12 ft16">#left(url.year,2)#<SPAN class="ft15">#right(url.year,2)#</SPAN></P></TD>
                                <TD class="tr4 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td7"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td8"><P class="p7 ft17">Miscellaneous</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td17" colspan=6><P class="p10 ft26">#qGetCompanyInformation.address#</P></TD>
                                <TD class="tr7 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr7 td10"><P class="p11 ft12"><SPAN class="ft11">2 </SPAN>Royalties</P></TD>
                                <TD class="tr7 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td7"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td8"><P class="p14 ft18">Income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr8 td17" colspan=6><P class="p10 ft26">#qGetCompanyInformation.address2#</P></TD>
                                <TD class="tr8 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td22"><P class="p13 ft9">$</P></TD>
                                <TD class="tr9 td23"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr9 td24"><P class="p12 ft19"><SPAN class="ft12">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr9 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td25"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td26"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td17" colspan=6><P class="p10 ft26">#qGetCompanyInformation.city#,#qGetCompanyInformation.state# #qGetCompanyInformation.zipcode#</P></TD>
                                <TD class="tr10 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr10 td10"><P class="p11 ft12"><SPAN class="ft11">3 </SPAN>Other income</P></TD>
                                <TD colspan=4 class="tr10 td27"><P class="p15 ft12"><SPAN class="ft11">4 </SPAN>Federal income tax withheld</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft20">Copy A</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td28"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td29"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td30"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td31"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td32"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td22"><P class="p13 ft9">$</P></TD>
                                <TD class="tr7 td23"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td4"><P class="p13 ft9">$</P></TD>
                                <TD class="tr7 td5"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td33"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td8"><P class="p16 ft21">For</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td17"><P class="p10 ft12">PAYER'S TIN</P></TD>
                                <TD class="tr2 td18"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td34"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr2 td35"><P class="p9 ft12">RECIPIENT'S TIN</P></TD>
                                <TD class="tr2 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr2 td10"><P class="p11 ft12"><SPAN class="ft11">5 </SPAN>Fishing boat proceeds</P></TD>
                                <TD colspan=4 class="tr2 td27"><P class="p15 ft10"><SPAN class="ft22">6 </SPAN>Medical and health care payments</P></TD>
                                <TD class="tr2 td8"><P class="p11 ft23">Internal Revenue</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr12 td17"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td18"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td34"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td19"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td20"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td21"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td13"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td14"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td15"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td6"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td36"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td6"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td37"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr10 td8"><P class="p16 ft25">Service Center</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td38"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td39"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td40"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td41"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td42"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td43"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td44"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td45"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td46"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td47"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td48"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td47"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td49"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr13 td38"><P class="p10 ft26">#qGetSystemConfig.TIN#</P></TD>
                                <TD class="tr13 td39"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td40"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td41"><P class="p10 ft26">#qForm1099.irs_ein#</P></TD>
                                <TD class="tr13 td42"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td43"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td44"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td45"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td46"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td47"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td48"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td47"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td49"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr14 td28"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td50"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td29"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td30"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td31"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td32"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td22"><P class="p13 ft9">$</P></TD>
                                <TD class="tr14 td23"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td4"><P class="p13 ft9">$</P></TD>
                                <TD class="tr14 td5"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td33"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr14 td26"><P class="p16 ft26">File with Form 1096.</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td17"><P class="p10 ft12">RECIPIENT'S name</P></TD>
                                <TD class="tr10 td18"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td18"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr10 td10"><P class="p11 ft10"><SPAN class="ft22">7 </SPAN>Nonemployee compensation</P></TD>
                                <TD colspan=4 class="tr10 td27"><P class="p15 ft10"><SPAN class="ft22">8 </SPAN>Substitute payments in lieu of</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft27">For Privacy Act</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td17" colspan=6><P class="p10 ft26">#qform1099.carriername#</P></TD>
                       
                                <TD class="tr3 td13"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td45"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td46"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=3 class="tr3 td51"><P class="p17 ft13">dividends or interest</P></TD>
                                <TD class="tr3 td49"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr14 td8"><P class="p17 ft9">and Paperwork</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr15 td17"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td18"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td18"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td19"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td20"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td21"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td13"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td45"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td46"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td6"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td36"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td6"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td49"><P class="p7 ft28">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td28"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td29"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td30"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td31"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td32"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td52"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td53"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td54"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td55"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td54"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td56"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td8"><P class="p18 ft9">Reduction Act</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=3 class="tr3 td57"><P class="p10 ft13">Street address (including apt. no.)</P></TD>
                                <TD class="tr3 td19"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td20"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td21"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td13"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td14"><P class="p13 ft29">$</P></TD>
                                <TD class="tr3 td15"><P class="p10 ft23">#NumberFormat(qForm1099.TotalCarrierCharges, '0.00')#</P></TD>
                                <TD class="tr3 td6"><P class="p13 ft29">$</P></TD>
                                <TD class="tr3 td36"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td6"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td37"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p19 ft29">Notice, see the</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr16 td17"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td18"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td18"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td19"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td20"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td21"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td13"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr12 td22"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td23"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td4"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD colspan=3 class="tr12 td23"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr17 td8"><P class="p16 ft31">2018 General</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td17"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td18"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td18"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td19"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td20"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td21"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td13"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 class="tr3 td10"><P class="p11 ft13"><SPAN class="ft11">9 </SPAN>Payer made direct sales of</P></TD>
                                <TD colspan=4 class="tr3 td27"><P class="p20 ft13"><SPAN class="ft11">10 </SPAN>Crop insurance proceeds</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td17" colspan=6><P class="p11 ft26">#qForm1099.Address#</P></TD>
                                
                                <TD class="tr10 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr10 td10"><P class="p19 ft12">$5,000 or more of consumer</P></TD>
                                <TD class="tr10 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td36"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td37"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft20">Instructions for</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td28"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td1"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td1"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td29"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td30"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td31"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td32"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD colspan=2 rowspan=2 class="tr19 td10"><P class="p19 ft33">products to a buyer</P></TD>
                                <TD rowspan=4 class="tr20 td4"><P class="p13 ft9">$</P></TD>
                                <TD class="tr21 td36"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td6"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td37"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD rowspan=3 class="tr17 td8"><P class="p16 ft31">Certain</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=7 rowspan=3 class="tr14 td9"><P class="p10 ft12">City or town, state or province, country, and ZIP or foreign postal code</P></TD>
                                <TD class="tr12 td36"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td6"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td37"><P class="p7 ft24">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=2 rowspan=2 class="tr2 td58"><P class="p19 ft12">(recipient) for resale &##9658</P></TD>
                                <TD class="tr15 td36"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td6"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td37"><P class="p7 ft28">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr21 td5"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td4"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td33"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr10 td8"><P class="p16 ft20">Information</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td17"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td18"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td18"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td19"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td20"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td21"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td13"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td14"><P class="p13 ft11">11</P></TD>
                                <TD class="tr18 td46"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td6"><P class="p13 ft11">12</P></TD>
                                <TD class="tr18 td48"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td47"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td49"><P class="p7 ft32">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td17" colspan=6><P class="p10 ft26">#qForm1099.City#,#trim(qForm1099.stateCode)# #qForm1099.ZipCode#</P></TD>
                                <TD class="tr18 td13"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td46"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td48"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td47"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td49"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=3 class="tr14 td8"><P class="p16 ft36">Returns.</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr12 td17"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td18"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td18"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td19"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td20"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td21"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td13"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td14"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td46"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td6"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td48"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td47"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td49"><P class="p7 ft24">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr21 td17"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td18"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td18"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td19"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td20"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td21"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td13"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td45"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td46"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td47"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td48"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td47"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td49"><P class="p7 ft34">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=3 class="tr22 td59"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td29"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td30"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td31"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td32"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td60"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td61"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td62"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD colspan=2 class="tr22 td63"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td64"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr19 td8"><P class="p7 ft38">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=2 class="tr17 td65"><P class="p10 ft12">Account number (see instructions)</P></TD>
                                <TD class="tr10 td66"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td67"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td68"><P class="p21 ft12">FATCA filing</P></TD>
                                <TD class="tr17 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td13"><P class="p7 ft12">2nd TIN not.</P></TD>
                                <TD colspan=2 class="tr17 td10"><P class="p20 ft12"><SPAN class="ft11">13 </SPAN>Excess golden parachute</P></TD>
                                <TD colspan=4 class="tr17 td27"><P class="p20 ft12"><SPAN class="ft11">14 </SPAN>Gross proceeds paid to an</P></TD>
                                <TD class="tr17 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr23 td17"><P class="p7 ft39">&nbsp;</P></TD>
                                <TD class="tr23 td18"><P class="p7 ft39">&nbsp;</P></TD>
                                <TD class="tr23 td18"><P class="p7 ft39">&nbsp;</P></TD>
                                <TD class="tr23 td69"><P class="p7 ft39">&nbsp;</P></TD>
                                <TD class="tr23 td68"><P class="p21 ft40">requirement</P></TD>
                                <TD class="tr23 td21"><P class="p7 ft39">&nbsp;</P></TD>
                                <TD class="tr23 td13"><P class="p7 ft39">&nbsp;</P></TD>
                                <TD colspan=2 class="tr23 td10"><P class="p22 ft40">payments</P></TD>
                                <TD colspan=4 class="tr23 td27"><P class="p19 ft40">attorney</P></TD>
                                <TD class="tr23 td8"><P class="p7 ft39">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr4 td28"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td70"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td71"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td31"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td32"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td22"><P class="p13 ft9">$</P></TD>
                                <TD class="tr4 td23"><P class="p7 ft8">&nnbsp;</P></TD>
                                <TD class="tr4 td4"><P class="p13 ft9">$</P></TD>
                                <TD class="tr4 td5"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td33"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td26"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td17"><P class="p21 ft12"><SPAN class="ft11">15a </SPAN>Section 409A deferrals</P></TD>
                                <TD class="tr2 td18"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td34"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr2 td35"><P class="p20 ft12"><SPAN class="ft11">15b </SPAN>Section 409A income</P></TD>
                                <TD class="tr2 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr2 td10"><P class="p20 ft12"><SPAN class="ft11">16 </SPAN>State tax withheld</P></TD>
                                <TD colspan=4 class="tr2 td27"><P class="p20 ft12"><SPAN class="ft11">17 </SPAN>State/Payer's state no.</P></TD>
                                <TD class="tr2 td8"><P class="p23 ft12"><SPAN class="ft11">18 </SPAN>State income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td17"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td18"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td34"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td13"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td14"><P class="p13 ft9">$</P></TD>
                                <TD class="tr11 td15"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td36"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td6"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td37"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td8"><P class="p24 ft9">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td28"><P class="p10 ft9">$</P></TD>
                                <TD class="tr7 td1"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td50"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td29"><P class="p9 ft9">$</P></TD>
                                <TD class="tr7 td30"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td31"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td32"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td22"><P class="p13 ft9">$</P></TD>
                                <TD class="tr7 td23"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td5"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td4"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td33"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td26"><P class="p24 ft9">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td72"><P class="p25 ft41"><SPAN class="ft12">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD colspan=5 class="tr24 td73"><P class="p7 ft12">Cat. No. 14425J</P></TD>
                                <TD colspan=3 class="tr24 td74"><P class="p26 ft12">www.irs.gov/Form1099MISC</P></TD>
                                <TD colspan=5 class="tr24 td75"><P class="p16 ft12">Department of the Treasury - Internal Revenue Service</P></TD>
                            </TR>
                        </TABLE>
                        <P class="p27 ft42">Do Not Cut or Separate Forms on This Page - Do Not Cut or Separate Forms on This Page</P>
                    </DIV>
                    <P style="page-break-before: always"></P>
                    </cfif>
                    <cfif url.copy eq 'Copy1'>
                    <DIV id="page_3">
                        <DIV id="p3dimg1">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAGvAgcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD0PwX4L8K3XgXw9cXHhrRpp5dMtnkkksImZ2MSkkkrkknnNSeJPCfhvTNPs7yw8P6VaXUeq6dsmgso43XN5CDhgMjIJH41J4a1DWtG8K6Rpdx4P1lp7Kyht5GjnsipZECkjNwDjI9BUmsXer63bWtlH4V1W2/4mFnM8081psRI7mORids7N91D0BoA7CiiigAooooAKKKKACuX8X2FnqeoeFrO/tILu1k1V98M8YkRsWdyRlTwcEA/hXUVz/ieK9+06De2WnT3/wBh1BppoYHjV9htp48jzHVT80i96AD/AIQTwf8A9Cpof/guh/8Aiar+ELCz0zUPFNnYWkFpax6qmyGCMRoubO2Jwo4GSSfxqx/wkOqf9CZrn/f6y/8AkijwxFe/adevb3Tp7D7dqCzQwzvGz7BbQR5Pluyj5o270AdBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQBzfjmCG68Nx29xFHNBLqenpJHIoZXU3kIIIPBBHGKk/4QTwf/wBCpof/AILof/iaueINKm1nSfslvcx2063FvcRyyRGVQ0UySgFQykglMdR1qn9j8Yf9B3Q//BNN/wDJVAEfgaCG18NyW9vFHDBFqeoJHHGoVUUXkwAAHAAHGK6Ss/RdM/sjTBambzpGlluJZAu0NJLI0j7VycLudsAkkDAJJ5OhQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUVj+JdWvNF0yK6srKC7ke7gtjHNcmEDzZFjVtwR+jOuRjpk9Rg1/tnjD/oBaH/AODmb/5FoA6Cis/QtT/tvw9pmreT5P260iufK3btm9A23OBnGcZwK0KACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigDl/H1/Z6f4ftZb27gtozqun4eaQIDtu4nbk+iqzH0Ck9BVj/hO/B/8A0Neh/wDgxh/+KroKKAOf8Cf8k88Nf9gq1/8ARS10FFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUV5/8A8Lt+Hn/Qw/8Aklcf/G6P+F2/Dz/oYf8AySuP/jdAHoFFZ+ia3p3iPR4NW0m4+0WM+7y5djJu2sVPDAEcgjkVx/8Awu34ef8AQw/+SVx/8boA9Aorz/8A4Xb8PP8AoYf/ACSuP/jddhomt6d4j0eDVtJuPtFjPu8uXYybtrFTwwBHII5FAGhRXn//AAu34ef9DD/5JXH/AMbo/wCF2/Dz/oYf/JK4/wDjdAHoFFZ+ia3p3iPR4NW0m4+0WM+7y5djJu2sVPDAEcgjkVx//C7fh5/0MP8A5JXH/wAboA9Aorz/AP4Xb8PP+hh/8krj/wCN12Gia3p3iPR4NW0m4+0WM+7y5djJu2sVPDAEcgjkUAaFFef/APC7fh5/0MP/AJJXH/xuj/hdvw8/6GH/AMkrj/43QB6BRWfomt6d4j0eDVtJuPtFjPu8uXYybtrFTwwBHII5Fcf/AMLt+Hn/AEMP/klcf/G6APQKK8//AOF2/Dz/AKGH/wAkrj/43R/wu34ef9DD/wCSVx/8boA9Aorz/wD4Xb8PP+hh/wDJK4/+N12Gt63p3hzR59W1a4+z2MG3zJdjPt3MFHCgk8kDgUAaFFef/wDC7fh5/wBDD/5JXH/xuj/hdvw8/wChh/8AJK4/+N0AegUVn63reneHNHn1bVrj7PYwbfMl2M+3cwUcKCTyQOBXH/8AC7fh5/0MP/klcf8AxugD0CivP/8Ahdvw8/6GH/ySuP8A43XYa3reneHNHn1bVrj7PYwbfMl2M+3cwUcKCTyQOBQBoUV5/wD8Lt+Hn/Qw/wDklcf/ABuj/hdvw8/6GH/ySuP/AI3QB6BRWfret6d4c0efVtWuPs9jBt8yXYz7dzBRwoJPJA4Fcf8A8Lt+Hn/Qw/8Aklcf/G6APQKK8/8A+F2/Dz/oYf8AySuP/jddhret6d4c0efVtWuPs9jBt8yXYz7dzBRwoJPJA4FAGhRXn/8Awu34ef8AQw/+SVx/8bo/4Xb8PP8AoYf/ACSuP/jdAHoFFef/APC7fh5/0MP/AJJXH/xurFh8X/Amp6jbWFnrvmXV1KkMKfZJxudiAoyUwMkjrQB3FFY/iTxTo3hHTo7/AFy8+yWskohV/KeTLkEgYQE9FP5Vy/8Awu34ef8AQw/+SVx/8boA9Aorh7D4v+BNT1G2sLPXfMurqVIYU+yTjc7EBRkpgZJHWug8SeKdG8I6dHf65efZLWSUQq/lPJlyCQMICein8qANiivP/wDhdvw8/wChh/8AJK4/+N1YsPi/4E1PUbaws9d8y6upUhhT7JONzsQFGSmBkkdaAO4orH8SeKdG8I6dHf65efZLWSUQq/lPJlyCQMICein8q5f/AIXb8PP+hh/8krj/AON0AegUVw9h8X/Amp6jbWFnrvmXV1KkMKfZJxudiAoyUwMkjrXQeJPFOjeEdOjv9cvPslrJKIVfynky5BIGEBPRT+VAGxRXn/8Awu34ef8AQw/+SVx/8booA//Z" id="p3img1">
                        </DIV>
                        <TABLE cellpadding=0 cellspacing=0 class="t1">
                            <TR>
                                <TD class="tr0 td76"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr0 td77"><P class="p8 ft43">VOID</P></TD>
                                <TD colspan=3 class="tr0 td78"><P class="p7 ft43">CORRECTED</P></TD>
                                <TD class="tr0 td79"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=5 rowspan=2 class="tr17 td83"><P class="p10 ft44">PAYER'S name, street address, city or town, state or province, country, ZIP</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">1</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Rents</P></TD>
                                <TD colspan=2 class="tr2 td86"><P class="p12 ft46">OMB No. <NOBR>1545-0115</NOBR></P></TD>
                                <TD class="tr2 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr12 td84"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td85"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td87"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td88"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td81"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td82"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td8"><P class="p7 ft24">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=4 class="tr3 td89"><P class="p10 ft47">or foreign postal code, and telephone no.</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD rowspan=3 class="tr25 td88"><P class="p29 ft49">#left(url.year,2)#<SPAN class="ft48">#right(url.year,2)#</SPAN></P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 rowspan=2 class="tr8 td35"><P class="p16 ft50">Miscellaneous</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr13 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.companyName#</P></TD>
                                <TD class="tr13 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr1 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td81"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.address#</P></TD>
                                <TD class="tr7 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td84"><P class="p28 ft45">2</P></TD>
                                <TD class="tr7 td85"><P class="p25 ft46">Royalties</P></TD>
                                <TD class="tr7 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td8"><P class="p14 ft51">Income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr8 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.address2#</P></TD>
                                <TD class="tr8 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr9 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr9 td95"><P class="p12 ft52"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr9 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td97"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.city#,#qGetCompanyInformation.state# #qGetCompanyInformation.zipcode#</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">3</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Other income</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">4</P></TD>
                                <TD colspan=2 class="tr2 td99"><P class="p21 ft44">Federal income tax withheld</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr0 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td104"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr0 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr0 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p16 ft53">Copy 1</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr17 td107"><P class="p10 ft46">PAYER'S TIN</P></TD>
                                <TD colspan=3 class="tr17 td108"><P class="p9 ft46">RECIPIENT'S TIN</P></TD>
                                <TD class="tr17 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td84"><P class="p28 ft45">5</P></TD>
                                <TD class="tr17 td85"><P class="p25 ft46">Fishing boat proceeds</P></TD>
                                <TD class="tr17 td87"><P class="p16 ft45">6</P></TD>
                                <TD colspan=3 class="tr17 td109"><P class="p21 ft44">Medical and health care payments</P></TD>
                                <TD class="tr17 td8"><P class="p16 ft54">For State Tax</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td107"><P class="p11 ft55_1">#qGetSystemConfig.TIN#</P></TD>
                                <TD class="tr10 td19"><P class="p11 ft55_1">#qForm1099.irs_ein#</P></TD>
                                <TD class="tr10 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td92"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td84"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft55">Department</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr26 td111"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td104"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr26 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr26 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr26 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91"><P class="p10 ft46">RECIPIENT'S name</P></TD>
                                <TD class="tr2 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td92"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">7</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Nonemployee compensation</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">8</P></TD>
                                <TD colspan=3 class="tr2 td109"><P class="p21 ft44">Substitute payments in lieu of</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91" colspan=4><P class="p11 ft55_1">#qForm1099.CarrierName#</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 class="tr3 td99"><P class="p20 ft47">dividends or interest</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr6 td91"><P class="p10 ft46">Street address (including apt. no.)</P></TD>
                                <TD class="tr6 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td92"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr27 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr27 td94"><P class="p11 ft55_1">#NumberFormat(qForm1099.TotalCarrierCharges, '0.00')#</P></TD>
                                <TD class="tr27 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr27 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr27 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr27 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91" colspan=4><P class="p11 ft55_1">#qForm1099.Address#</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">9</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Payer made direct sales of</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">10</P></TD>
                                <TD colspan=2 class="tr2 td99"><P class="p21 ft46">Crop insurance proceeds</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td19"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td20"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td92"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p25 ft47">$5,000 or more of consumer</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td110"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=5 rowspan=2 class="tr28 td83"><P class="p10 ft46">City or town, state or province, country, and ZIP or foreign postal code</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p25 ft47">products to a buyer</P></TD>
                                <TD rowspan=2 class="tr4 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr3 td110"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td93"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td94"><P class="p25 ft46">(recipient) for resale &##9658</P></TD>
                                <TD class="tr24 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91" colspan=4><P class="p11 ft55_1">#qForm1099.City#,#trim(qForm1099.stateCode)# #qForm1099.ZipCode#</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">11</P></TD>
                                <TD class="tr2 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">12</P></TD>
                                <TD class="tr2 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr0 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr0 td112"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td93"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td79"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr0 td113"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91"><P class="p30 ft46">Account number (see instructions)</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td114"><P class="p21 ft46">FATCA filing</P></TD>
                                <TD class="tr2 td92"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">13</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Excess golden parachute</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">14</P></TD>
                                <TD colspan=2 class="tr2 td99"><P class="p21 ft46">Gross proceeds paid to an</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td114"><P class="p21 ft47">requirement</P></TD>
                                <TD class="tr3 td92"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p20 ft47">payments</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 class="tr3 td99"><P class="p21 ft47">attorney</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr4 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td115"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td104"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr4 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr4 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td107"><P class="p21 ft46"><SPAN class="ft45">15a </SPAN>Section 409A deferrals</P></TD>
                                <TD colspan=3 class="tr2 td108"><P class="p20 ft46"><SPAN class="ft45">15b </SPAN>Section 409A income</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr2 td116"><P class="p20 ft46"><SPAN class="ft45">16 </SPAN>State tax withheld</P></TD>
                                <TD colspan=3 class="tr2 td117"><P class="p20 ft46"><SPAN class="ft45">17 </SPAN>State/Payer's state no.</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p23 ft46"><SPAN class="ft45">18 </SPAN>State income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td107"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td92"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td84"><P class="p28 ft43">$</P></TD>
                                <TD class="tr11 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td8"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td111"><P class="p10 ft43">$</P></TD>
                                <TD class="tr7 td102"><P class="p9 ft43">$</P></TD>
                                <TD class="tr7 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td104"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr7 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td79"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td98"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr14 td118"><P class="p25 ft53"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr14 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=5 class="tr14 td119"><P class="p31 ft46">www.irs.gov/Form1099MISC</P></TD>
                                <TD class="tr14 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=4 class="tr14 td120"><P class="p16 ft44">Department of the Treasury - Internal Revenue Service</P></TD>
                            </TR>
                        </TABLE>
                    </DIV>
                    <P style="page-break-before: always"></P>
                    </cfif>
                    <cfif url.copy eq 'CopyB-Copy2'>
                    <DIV id="page_4">
                        <DIV id="p4dimg1">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAGiAdIDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3+iiigCOeCG6t5be4ijmglQpJHIoZXUjBBB4II4xWH/wgng//AKFTQ/8AwXQ//E10FFAGXpvhrQdGuGuNL0TTbGdkKNJa2qRMVyDglQDjIBx7CtSiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA5PTbnxVrMVzd2+p6NbQLe3VvHFJpcsrBYp5IgSwuFBJCZ6DrVizvNetfFVppeqXmm3cF1ZXFwrWtk8DI0Twrg7pnBBEx7DoKz9B1620azu7K9stZWddTv3/d6PdyqVe6ldSGSMqQVYHIJ61ctbsa14ysb+0tr5LW00+6hme7sprbDySW5QASqpbIif7ucYGcZGQDqKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiuf8A+E78H/8AQ16H/wCDGH/4qtDTNd0fW/N/snVbG/8AJx5n2S4SXZnOM7ScZwevoaANCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA5/wACf8k88Nf9gq1/9FLRZ/8AJQ9Z/wCwVYf+jbuq9h4Qu9M062sLPxdrkdraxJDCnl2Z2ooAUZNvk4AHWtTStFGm3FxdzX93qF5cIkb3N0Iw3loWKIBGiLgF3OcZ+Y5JAAABqUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFfOnx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FFFAHlf/Cd+MP+hr1z/wAGM3/xVeqfALxLr2s+Or631TW9SvoF0yR1jurp5VDebEMgMSM4JGfc0UUAHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FeV/wDCd+MP+hr1z/wYzf8AxVFFAHqnwC8S69rPjq+t9U1vUr6BdMkdY7q6eVQ3mxDIDEjOCRn3NHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FFFAHlf/Cd+MP+hr1z/wAGM3/xVeqfALxLr2s+Or631TW9SvoF0yR1jurp5VDebEMgMSM4JGfc0UUAHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FeV/wDCd+MP+hr1z/wYzf8AxVFFAHqnwC8S69rPjq+t9U1vUr6BdMkdY7q6eVQ3mxDIDEjOCRn3NHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FFFAHlf/Cd+MP+hr1z/wAGM3/xVeqfALxLr2s+Or631TW9SvoF0yR1jurp5VDebEMgMSM4JGfc0UUAHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FeV/wDCd+MP+hr1z/wYzf8AxVFFAB/wnfjD/oa9c/8ABjN/8VR/wnfjD/oa9c/8GM3/AMVRRQB9F/ALVtS1nwLfXGqahd3066nIiyXUzSsF8qI4BYk4ySce5rxDxp408VWvjrxDb2/iXWYYItTuUjjjv5VVFErAAANgADjFFFAGH/wnfjD/AKGvXP8AwYzf/FV9F/ALVtS1nwLfXGqahd3066nIiyXUzSsF8qI4BYk4ySce5oooA8Q8aeNPFVr468Q29v4l1mGCLU7lI447+VVRRKwAADYAA4xWH/wnfjD/AKGvXP8AwYzf/FUUUAfRfwC1bUtZ8C31xqmoXd9OupyIsl1M0rBfKiOAWJOMknHua8Q8aeNPFVr468Q29v4l1mGCLU7lI447+VVRRKwAADYAA4xRRQBh/wDCd+MP+hr1z/wYzf8AxVfRfwC1bUtZ8C31xqmoXd9OupyIsl1M0rBfKiOAWJOMknHuaKKAPEPGnjTxVa+OvENvb+JdZhgi1O5SOOO/lVUUSsAAA2AAOMVh/wDCd+MP+hr1z/wYzf8AxVFFAH0X8AtW1LWfAt9capqF3fTrqciLJdTNKwXyojgFiTjJJx7mvEPGnjTxVa+OvENvb+JdZhgi1O5SOOO/lVUUSsAAA2AAOMUUUAYf/Cd+MP8Aoa9c/wDBjN/8VR/wnfjD/oa9c/8ABjN/8VRRQAf8J34w/wChr1z/AMGM3/xVfU/2+8/4UV/aP2uf7d/wjXn/AGnzD5nmfZt2/d13Z5z1zRRQB8sf8J34w/6GvXP/AAYzf/FUf8J34w/6GvXP/BjN/wDFUUUAfU/2+8/4UV/aP2uf7d/wjXn/AGnzD5nmfZt2/d13Z5z1zXyx/wAJ34w/6GvXP/BjN/8AFUUUAH/Cd+MP+hr1z/wYzf8AxVfU/wBvvP8AhRX9o/a5/t3/AAjXn/afMPmeZ9m3b93XdnnPXNFFAHyx/wAJ34w/6GvXP/BjN/8AFUf8J34w/wChr1z/AMGM3/xVFFAH1P8Ab7z/AIUV/aP2uf7d/wAI15/2nzD5nmfZt2/d13Z5z1zXyx/wnfjD/oa9c/8ABjN/8VRRQAf8J34w/wChr1z/AMGM3/xVFFFAH//Z" id="p4img1">
                        </DIV>
                        <P class="p32 ft43">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAOAA4DASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD0PwX4L8K3XgXw9cXHhrRpp5dMtnkkksImZ2MSkkkrkknnNbn/AAgng/8A6FTQ/wDwXQ//ABNXPDWmzaN4V0jS7ho2nsrKG3kaMkqWRApIyAcZHoK1KAP/2Q==" id="p4inl_img1"><IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAOAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5/or2D/hnHxh/0EtD/wC/83/xqigD/9k=" id="p4inl_img2"> CORRECTED (if checked)
                        </P>
                        <TABLE cellpadding=0 cellspacing=0 class="t1">
                            <TR>
                                <TD colspan=6 rowspan=2 class="tr14 td121"><P class="p10 ft44">PAYER'S name, street address, city or town, state or province, country, ZIP</P></TD>
                                <TD class="tr24 td122"><P class="p11 ft46"><SPAN class="ft45">1 </SPAN>Rents</P></TD>
                                <TD class="tr24 td123"><P class="p20 ft46">OMB No. <NOBR>1545-0115</NOBR></P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td124"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td125"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr12 td126"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td127"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td81"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td124"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td125"><P class="p7 ft24">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=5 class="tr3 td128"><P class="p10 ft47">or foreign postal code, and telephone no.</P></TD>
                                <TD class="tr3 td129"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td126"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD rowspan=3 class="tr25 td127"><P class="p33 ft49">#left(url.year,2)#<SPAN class="ft48">#right(url.year,2)#</SPAN></P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 rowspan=2 class="tr8 td35"><P class="p16 ft50">Miscellaneous</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr13 td130" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.companyName#</P></TD>
                                <TD class="tr13 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td133"><P class="p34 ft43">$</P></TD>
                                <TD class="tr13 td81"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td130"  colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.address#</P></TD>         
                                <TD class="tr7 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td126"><P class="p11 ft46"><SPAN class="ft45">2 </SPAN>Royalties</P></TD>
                                <TD class="tr7 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td124"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td125"><P class="p35 ft51">Income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr8 td130"  colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.address2#</P></TD>
                                <TD class="tr8 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr8 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td133"><P class="p34 ft43">$</P></TD>
                                <TD class="tr9 td134"><P class="p36 ft52"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr9 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td135"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td136"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td130"  colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.city#,#qGetCompanyInformation.state# #qGetCompanyInformation.zipcode#</P></TD>
                                <TD class="tr24 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td126"><P class="p11 ft46"><SPAN class="ft45">3 </SPAN>Other income</P></TD>
                                <TD colspan=2 class="tr24 td137"><P class="p9 ft44"><SPAN class="ft57">4 </SPAN>Federal income tax withheld</P></TD>
                                <TD class="tr24 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td125"><P class="p37 ft58">Copy B</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td139"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td140"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td141"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td142"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td133"><P class="p34 ft43">$</P></TD>
                                <TD class="tr11 td143"><P class="p38 ft43">$</P></TD>
                                <TD class="tr11 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td144"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td125"><P class="p16 ft54">For Recipient</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td130"><P class="p10 ft46">PAYER'S TIN</P></TD>
                                <TD class="tr2 td145"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr2 td146"><P class="p9 ft46">RECIPIENT'S TIN</P></TD>
                                <TD class="tr2 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td126"><P class="p11 ft46"><SPAN class="ft45">5 </SPAN>Fishing boat proceeds</P></TD>
                                <TD colspan=3 class="tr2 td147"><P class="p9 ft44"><SPAN class="ft57">6 </SPAN>Medical and health care payments</P></TD>
                                <TD class="tr2 td125"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr29 td139"><P class="p11 ft55_1">#qGetSystemConfig.TIN#</P></TD>
                                <TD class="tr29 td148"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td102"><P class="p11 ft55_1">#qForm1099.irs_ein#</P></TD>
                                <TD class="tr29 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td141"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td142"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td133"><P class="p34 ft43">$</P></TD>
                                <TD class="tr29 td143"><P class="p38 ft43">$</P></TD>
                                <TD class="tr29 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td144"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td136"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td130"><P class="p10 ft46">RECIPIENT'S name</P></TD>
                                <TD class="tr2 td131"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td126"><P class="p11 ft46"><SPAN class="ft45">7 </SPAN>Nonemployee compensation</P></TD>
                                <TD colspan=3 class="tr2 td147"><P class="p9 ft44"><SPAN class="ft57">8 </SPAN>Substitute payments in lieu of</P></TD>
                                <TD rowspan=2 class="tr20 td125"><P class="p16 ft59">This is important tax</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr19 td130" colspan=4><P class="p11 ft55_1">#qForm1099.CarrierName#</P></TD>
                                <TD class="tr19 td132"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD class="tr19 td129"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD class="tr19 td126"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD colspan=2 class="tr19 td137"><P class="p39 ft60">dividends or interest</P></TD>
                                <TD class="tr19 td138"><P class="p7 ft38">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td130"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td131"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td126"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td149"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td125"><P class="p16 ft61">information and is</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td130"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td131"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td126"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td149"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td125"><P class="p16 ft61">being furnished to</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=2 class="tr10 td91"><P class="p10 ft46">Street address (including apt. no.)</P></TD>
                                <TD class="tr10 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td126"><P class="p11 ft55_1">$#NumberFormat(qForm1099.TotalCarrierCharges, '0.00')#</P></TD>
                                <TD class="tr10 td149"><P class="p38 ft62">$</P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td125"><P class="p16 ft59">the IRS. If you are</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr16 td130"><P class="p11 ft55_1">#qForm1099.Address#</P></TD>
                                <TD class="tr16 td131"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td19"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td20"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td132"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td129"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr12 td133"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td143"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td96"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td144"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr19 td125"><P class="p16 ft63">required to file a</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td130"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td131"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td19"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td20"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td132"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td129"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td126"><P class="p11 ft46"><SPAN class="ft45">9 </SPAN>Payer made direct sales of</P></TD>
                                <TD colspan=2 rowspan=2 class="tr2 td137"><P class="p7 ft46"><SPAN class="ft45">10 </SPAN>Crop insurance proceeds</P></TD>
                                <TD class="tr18 td138"><P class="p7 ft32">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td130"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td131"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td19"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td20"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td132"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td129"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td138"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td125"><P class="p16 ft61">return, a negligence</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td130"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td131"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td19"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td20"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td132"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td129"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr3 td126"><P class="p19 ft47">$5,000 or more of consumer</P></TD>
                                <TD class="tr18 td149"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td81"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td138"><P class="p7 ft32">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr15 td130"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td131"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td19"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td20"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td132"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td129"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td149"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td81"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD class="tr15 td138"><P class="p7 ft28">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td125"><P class="p16 ft61">penalty or other</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr21 td130"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td131"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td19"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td20"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td132"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td129"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr3 td126"><P class="p19 ft47">products to a buyer</P></TD>
                                <TD class="tr21 td149"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td81"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td138"><P class="p7 ft34">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=5 rowspan=2 class="tr10 td128"><P class="p10 ft44">City or town, state or province, country, and ZIP or foreign postal code</P></TD>
                                <TD class="tr16 td129"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr10 td149"><P class="p38 ft62">$</P></TD>
                                <TD class="tr16 td81"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td138"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr10 td125"><P class="p16 ft59">sanction may be</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr19 td129"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD class="tr19 td126"><P class="p19 ft60">(recipient) for resale &##9658</P></TD>
                                <TD class="tr19 td81"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD class="tr19 td138"><P class="p7 ft38">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr16 td130"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td131"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td19"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td20"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td132"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td129"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr12 td133"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td143"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td96"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td144"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr19 td125"><P class="p16 ft63">imposed on you if</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td130" colspan=4><P class="p11 ft55_1">#qForm1099.City#,#trim(qForm1099.stateCode)# #qForm1099.ZipCode#</P></TD>
                                <TD class="tr18 td132"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td129"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td126"><P class="p34 ft45">11</P></TD>
                                <TD rowspan=2 class="tr2 td149"><P class="p38 ft45">12</P></TD>
                                <TD class="tr18 td81"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td138"><P class="p7 ft32">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td130"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td131"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td19"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td20"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td132"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td129"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td81"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td138"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr2 td125"><P class="p16 ft61">this income is</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr18 td130"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td131"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td19"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td20"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td132"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td129"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td126"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td149"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td81"><P class="p7 ft32">&nbsp;</P></TD>
                                <TD class="tr18 td138"><P class="p7 ft32">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td139"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td140"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td141"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td142"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td133"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td143"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td144"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td125"><P class="p16 ft64">taxable and the IRS</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=2 class="tr2 td91"><P class="p10 ft46">Account number (see instructions)</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td114"><P class="p21 ft46">FATCA filing</P></TD>
                                <TD class="tr2 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td126"><P class="p20 ft46"><SPAN class="ft45">13 </SPAN>Excess golden parachute</P></TD>
                                <TD colspan=2 class="tr2 td137"><P class="p7 ft46"><SPAN class="ft45">14 </SPAN>Gross proceeds paid to an</P></TD>
                                <TD class="tr2 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td125"><P class="p40 ft61">determines that it</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td130"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td131"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td114"><P class="p21 ft47">requirement</P></TD>
                                <TD class="tr3 td132"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td129"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td126"><P class="p22 ft47">payments</P></TD>
                                <TD colspan=2 class="tr3 td137"><P class="p41 ft47">attorney</P></TD>
                                <TD class="tr3 td138"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td125"><P class="p16 ft65">has not been</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td130"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td131"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td114"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr28 td133"><P class="p34 ft43">$</P></TD>
                                <TD rowspan=2 class="tr28 td143"><P class="p38 ft43">$</P></TD>
                                <TD class="tr24 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td125"><P class="p16 ft64">reported.</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td139"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td140"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td115"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td141"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td142"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td144"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td136"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td130"><P class="p21 ft46"><SPAN class="ft45">15a </SPAN>Section 409A deferrals</P></TD>
                                <TD class="tr2 td145"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr2 td146"><P class="p20 ft46"><SPAN class="ft45">15b </SPAN>Section 409A income</P></TD>
                                <TD class="tr2 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td126"><P class="p20 ft46"><SPAN class="ft45">16 </SPAN>State tax withheld</P></TD>
                                <TD colspan=2 class="tr2 td137"><P class="p7 ft46"><SPAN class="ft45">17 </SPAN>State/Payer's state no.</P></TD>
                                <TD class="tr2 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td125"><P class="p23 ft46"><SPAN class="ft45">18 </SPAN>State income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td130"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td145"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td132"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td129"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td126"><P class="p34 ft43">$</P></TD>
                                <TD class="tr11 td149"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td138"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td125"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td139"><P class="p10 ft43">$</P></TD>
                                <TD class="tr7 td148"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td102"><P class="p9 ft43">$</P></TD>
                                <TD class="tr7 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td141"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td142"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td133"><P class="p34 ft43">$</P></TD>
                                <TD class="tr7 td143"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td144"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td136"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr14 td150"><P class="p25 ft53"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD colspan=4 class="tr14 td151"><P class="p7 ft59">(keep for your records)</P></TD>
                                <TD colspan=2 class="tr14 td152"><P class="p7 ft46">www.irs.gov/Form1099MISC</P></TD>
                                <TD colspan=4 class="tr14 td153"><P class="p16 ft46">Department of the Treasury - Internal Revenue Service</P></TD>
                            </TR>
                        </TABLE>
                    </DIV>
                    <P style="page-break-before: always">
                    <DIV id="page_5">
                        <DIV>
                            <DIV id="id5_1">
                                <P class="p27 ft53">Instructions for Recipient</P>
                                <P class="p42 ft45">Recipient's taxpayer identification number (TIN). <SPAN class="ft47">For your protection, this form may show only the last four digits of your social security number (SSN), individual taxpayer identification number (ITIN), adoption taxpayer identification number (ATIN), or employer identification number (EIN). However, the issuer has reported your complete TIN to the IRS.</SPAN></P>
                                <P class="p43 ft47"><SPAN class="ft45">Account number. </SPAN>May show an account or other unique number the payer assigned to distinguish your account.</P>
                                <P class="p44 ft67"><SPAN class="ft66">FATCA filing requirement. </SPAN>If the FATCA filing requirement box is checked, the payer is reporting on this Form 1099 to satisfy its chapter 4 account reporting requirement. You also may have a filing requirement. See the Instructions for Form 8938.</P>
                                <P class="p45 ft66">Amounts shown may be subject to <NOBR>self-employment</NOBR> (SE) tax. <SPAN class="ft67">If your net income from </SPAN><NOBR><SPAN class="ft67">self-employment</SPAN></NOBR><SPAN class="ft67"> is $400 or more, you must file a return and compute your SE tax on Schedule SE (Form 1040). See Pub. 334 for more information. If no income or social security and Medicare taxes were withheld and you are still receiving these payments, see Form </SPAN><NOBR><SPAN class="ft67">1040-ES</SPAN></NOBR><SPAN class="ft67"> (or Form </SPAN><NOBR><SPAN class="ft67">1040-ES(NR)).</SPAN></NOBR><SPAN class="ft67"> Individuals must report these amounts as explained in the box 7 instructions on this page. Corporations, fiduciaries, or partnerships must report the amounts on the proper line of their tax returns.</SPAN></P>
                                <P class="p46 ft47"><SPAN class="ft45">Form </SPAN><NOBR><SPAN class="ft45">1099-MISC</SPAN></NOBR><SPAN class="ft45"> incorrect? </SPAN>If this form is incorrect or has been issued in error, contact the payer. If you cannot get this form corrected, attach an explanation to your tax return and report your income correctly.</P>
                                <P class="p47 ft67"><SPAN class="ft66">Box 1. </SPAN>Report rents from real estate on Schedule E (Form 1040). However, report rents on Schedule C (Form 1040) if you provided significant services to the tenant, sold real estate as a business, or rented personal property as a business. See Pub. 527.</P>
                                <P class="p47 ft67"><SPAN class="ft66">Box 2. </SPAN>Report royalties from oil, gas, or mineral properties, copyrights, and patents on Schedule E (Form 1040). However, report payments for a working interest as explained in the box 7 instructions. For royalties on timber, coal, and iron ore, see Pub. 544.</P>
                                <P class="p45 ft44"><SPAN class="ft57">Box 3. </SPAN>Generally, report this amount on the "Other income" line of Form 1040 (or Form 1040NR) and identify the payment. The amount shown may be payments received as the beneficiary of a deceased employee, prizes, awards, taxable damages, Indian gaming profits, or other taxable income. See Pub. 525. If it is trade or business income, report this amount on Schedule C or F (Form 1040).</P>
                                <P class="p48 ft47"><SPAN class="ft45">Box 4. </SPAN>Shows backup withholding or withholding on Indian gaming profits. Generally, a payer must backup withhold if you did not furnish your TIN. See Form <NOBR>W-9</NOBR> and Pub. 505 for more information. Report this amount on your income tax return as tax withheld.</P>
                                <P class="p49 ft44"><SPAN class="ft57">Box 5. </SPAN>An amount in this box means the fishing boat operator considers you self- employed. Report this amount on Schedule C (Form 1040). See Pub. 334.</P>
                                <P class="p50 ft46"><SPAN class="ft45">Box 6. </SPAN>For individuals, report on Schedule C (Form 1040).</P>
                            </DIV>
                            <DIV id="id5_2">
                                <P class="p51 ft44"><SPAN class="ft57">Box 7. </SPAN>Shows nonemployee compensation. If you are in the trade or business of catching fish, box 7 may show cash you received for the sale of fish. If the amount in this box is SE income, report it on Schedule C or F (Form 1040), and complete Schedule SE (Form 1040). You received this form instead of Form <NOBR>W-2</NOBR> because the payer did not consider you an employee and did not withhold income tax or social security and Medicare tax. If you believe you are an employee and cannot get the payer to correct this form, report this amount on the line for "Wages, salaries, tips, etc." of Form 1040 (or Form 1040NR). You must also complete Form 8919 and attach it to your return. If you are not an employee but the amount in this box is not SE income (for example, it is income from a sporadic activity or a hobby), report this amount on the "Other income" line of Form 1040 (or Form 1040NR).</P>
                                <P class="p52 ft47"><SPAN class="ft45">Box 8. </SPAN>Shows substitute payments in lieu of dividends or <NOBR>tax-exempt</NOBR> interest received by your broker on your behalf as a result of a loan of your securities. Report on the "Other income" line of Form 1040 (or Form 1040NR).</P>
                                <P class="p53 ft47"><SPAN class="ft45">Box 9. </SPAN>If checked, $5,000 or more of sales of consumer products was paid to you on a <NOBR>buy-sell,</NOBR> <NOBR>deposit-commission,</NOBR> or other basis. A dollar amount does not have to be shown. Generally, report any income from your sale of these products on Schedule C (Form 1040).</P>
                                <P class="p54 ft46"><SPAN class="ft45">Box 10. </SPAN>Report this amount on Schedule F (Form 1040).</P>
                                <P class="p55 ft47"><SPAN class="ft45">Box 13. </SPAN>Shows your total compensation of excess golden parachute payments subject to a 20% excise tax. See the Form 1040 (or Form 1040NR) instructions for where to report.</P>
                                <P class="p56 ft46"><SPAN class="ft45">Box 14. </SPAN>Shows gross proceeds paid to an attorney in connection with legal services. Report only the taxable part as income on your return.</P>
                                <P class="p57 ft44"><SPAN class="ft57">Box 15a. </SPAN>May show current year deferrals as a nonemployee under a nonqualified deferred compensation (NQDC) plan that is subject to the requirements of section 409A, plus any earnings on current and prior year deferrals.</P>
                                <P class="p58 ft47"><SPAN class="ft45">Box 15b. </SPAN>Shows income as a nonemployee under an NQDC plan that does not meet the requirements of section 409A. This amount is also included in box 7 as nonemployee compensation. Any amount included in box 15a that is currently taxable is also included in this box. This income is also subject to a substantial additional tax to be reported on Form 1040 (or Form 1040NR). See the Form 1040 (or Form 1040NR) instructions.</P>
                                <P class="p54 ft46"><SPAN class="ft45">Boxes </SPAN><NOBR><SPAN class="ft45">16-18.</SPAN></NOBR><SPAN class="ft45"> </SPAN>Shows state or local income tax withheld from the payments.</P>
                                <P class="p59 ft46"><SPAN class="ft45">Future developments. </SPAN>For the latest information about developments related to Form <NOBR>1099-MISC</NOBR> and its instructions, such as legislation enacted after they were published, go to <SPAN class="ft68">www.irs.gov/Form1099MISC</SPAN>.</P>
                            </DIV>
                        </DIV>
                    </DIV>
                    <P style="page-break-before: always">
                    <DIV id="page_6">
                        <DIV id="p6dimg1">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAGiAdIDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD3+iiigCOeCG6t5be4ijmglQpJHIoZXUjBBB4II4xWH/wgng//AKFTQ/8AwXQ//E10FFAGXpvhrQdGuGuNL0TTbGdkKNJa2qRMVyDglQDjIBx7CtSiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA5PTbnxVrMVzd2+p6NbQLe3VvHFJpcsrBYp5IgSwuFBJCZ6DrVizvNetfFVppeqXmm3cF1ZXFwrWtk8DI0Twrg7pnBBEx7DoKz9B1620azu7K9stZWddTv3/d6PdyqVe6ldSGSMqQVYHIJ61ctbsa14ysb+0tr5LW00+6hme7sprbDySW5QASqpbIif7ucYGcZGQDqKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiuf8A+E78H/8AQ16H/wCDGH/4qtDTNd0fW/N/snVbG/8AJx5n2S4SXZnOM7ScZwevoaANCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA5/wACf8k88Nf9gq1/9FLRZ/8AJQ9Z/wCwVYf+jbuq9h4Qu9M062sLPxdrkdraxJDCnl2Z2ooAUZNvk4AHWtTStFGm3FxdzX93qF5cIkb3N0Iw3loWKIBGiLgF3OcZ+Y5JAAABqUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFfOnx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FFFAHlf/Cd+MP+hr1z/wAGM3/xVeqfALxLr2s+Or631TW9SvoF0yR1jurp5VDebEMgMSM4JGfc0UUAHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FeV/wDCd+MP+hr1z/wYzf8AxVFFAHqnwC8S69rPjq+t9U1vUr6BdMkdY7q6eVQ3mxDIDEjOCRn3NHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FFFAHlf/Cd+MP+hr1z/wAGM3/xVeqfALxLr2s+Or631TW9SvoF0yR1jurp5VDebEMgMSM4JGfc0UUAHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FeV/wDCd+MP+hr1z/wYzf8AxVFFAHqnwC8S69rPjq+t9U1vUr6BdMkdY7q6eVQ3mxDIDEjOCRn3NHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FFFAHlf/Cd+MP+hr1z/wAGM3/xVeqfALxLr2s+Or631TW9SvoF0yR1jurp5VDebEMgMSM4JGfc0UUAHx98S69o3jqxt9L1vUrGBtMjdo7W6eJS3myjJCkDOABn2FeV/wDCd+MP+hr1z/wYzf8AxVFFAB/wnfjD/oa9c/8ABjN/8VR/wnfjD/oa9c/8GM3/AMVRRQB9F/ALVtS1nwLfXGqahd3066nIiyXUzSsF8qI4BYk4ySce5rxDxp408VWvjrxDb2/iXWYYItTuUjjjv5VVFErAAANgADjFFFAGH/wnfjD/AKGvXP8AwYzf/FV9F/ALVtS1nwLfXGqahd3066nIiyXUzSsF8qI4BYk4ySce5oooA8Q8aeNPFVr468Q29v4l1mGCLU7lI447+VVRRKwAADYAA4xWH/wnfjD/AKGvXP8AwYzf/FUUUAfRfwC1bUtZ8C31xqmoXd9OupyIsl1M0rBfKiOAWJOMknHua8Q8aeNPFVr468Q29v4l1mGCLU7lI447+VVRRKwAADYAA4xRRQBh/wDCd+MP+hr1z/wYzf8AxVfRfwC1bUtZ8C31xqmoXd9OupyIsl1M0rBfKiOAWJOMknHuaKKAPEPGnjTxVa+OvENvb+JdZhgi1O5SOOO/lVUUSsAAA2AAOMVh/wDCd+MP+hr1z/wYzf8AxVFFAH0X8AtW1LWfAt9capqF3fTrqciLJdTNKwXyojgFiTjJJx7mvEPGnjTxVa+OvENvb+JdZhgi1O5SOOO/lVUUSsAAA2AAOMUUUAYf/Cd+MP8Aoa9c/wDBjN/8VR/wnfjD/oa9c/8ABjN/8VRRQAf8J34w/wChr1z/AMGM3/xVfU/2+8/4UV/aP2uf7d/wjXn/AGnzD5nmfZt2/d13Z5z1zRRQB8sf8J34w/6GvXP/AAYzf/FUf8J34w/6GvXP/BjN/wDFUUUAfU/2+8/4UV/aP2uf7d/wjXn/AGnzD5nmfZt2/d13Z5z1zXyx/wAJ34w/6GvXP/BjN/8AFUUUAH/Cd+MP+hr1z/wYzf8AxVfU/wBvvP8AhRX9o/a5/t3/AAjXn/afMPmeZ9m3b93XdnnPXNFFAHyx/wAJ34w/6GvXP/BjN/8AFUf8J34w/wChr1z/AMGM3/xVFFAH1P8Ab7z/AIUV/aP2uf7d/wAI15/2nzD5nmfZt2/d13Z5z1zXyx/wnfjD/oa9c/8ABjN/8VRRQAf8J34w/wChr1z/AMGM3/xVFFFAH//Z" id="p6img1">
                        </DIV>
                        <P class="p32 ft43">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAOAA4DASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD0PwX4L8K3XgXw9cXHhrRpp5dMtnkkksImZ2MSkkkrkknnNbn/AAgng/8A6FTQ/wDwXQ//ABNXPDWmzaN4V0jS7ho2nsrKG3kaMkqWRApIyAcZHoK1KAP/2Q==" id="p6inl_img1"><IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAOAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD5/or2D/hnHxh/0EtD/wC/83/xqigD/9k=" id="p6inl_img2"> CORRECTED (if checked)
                        </P>
                        <TABLE cellpadding=0 cellspacing=0 class="t1">
                            <TR>
                                <TD colspan=4 rowspan=2 class="tr14 td121"><P class="p10 ft44">PAYER'S name, street address, city or town, state or province, country, ZIP</P></TD>
                                <TD class="tr24 td154"><P class="p28 ft45">1</P></TD>
                                <TD class="tr24 td155"><P class="p25 ft46">Rents</P></TD>
                                <TD colspan=2 class="tr24 td156"><P class="p30 ft46">OMB No. <NOBR>1545-0115</NOBR></P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr12 td84"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td85"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td87"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td88"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td81"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td82"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td8"><P class="p7 ft24">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=4 class="tr3 td83"><P class="p10 ft47">or foreign postal code, and telephone no.</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD rowspan=3 class="tr25 td88"><P class="p29 ft49">#left(url.year,2)#<SPAN class="ft48">#right(url.year,2)#</SPAN></P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 rowspan=2 class="tr8 td35"><P class="p16 ft50">Miscellaneous</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr13 td91" colspan=3><P class="p11 ft55_1">#qGetCompanyInformation.companyName#</P>
</TD>
                                
                                <TD class="tr13 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr1 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr13 td81"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td91" colspan=3><P class="p11 ft55_1">#qGetCompanyInformation.address#</P></TD>
                                <TD class="tr7 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td84"><P class="p28 ft45">2</P></TD>
                                <TD class="tr7 td85"><P class="p25 ft46">Royalties</P></TD>
                                <TD class="tr7 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td8"><P class="p14 ft51">Income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr8 td91" colspan=3><P class="p11 ft55_1">#qGetCompanyInformation.address2#</P></TD>
                                <TD class="tr8 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr9 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr9 td95"><P class="p12 ft52"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr9 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td97"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91" colspan=3><P class="p11 ft55_1">#qGetCompanyInformation.city#,#qGetCompanyInformation.state# #qGetCompanyInformation.zipcode#</P></TD>
                                <TD class="tr2 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">3</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Other income</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">4</P></TD>
                                <TD colspan=2 class="tr2 td99"><P class="p21 ft44">Federal income tax withheld</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr0 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td158"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr0 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr0 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p16 ft53">Copy 2</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr17 td107"><P class="p10 ft46">PAYER'S TIN</P></TD>
                                <TD colspan=3 class="tr17 td159"><P class="p9 ft46">RECIPIENT'S TIN</P></TD>
                                <TD class="tr17 td84"><P class="p28 ft45">5</P></TD>
                                <TD class="tr17 td85"><P class="p25 ft46">Fishing boat proceeds</P></TD>
                                <TD class="tr17 td87"><P class="p16 ft45">6</P></TD>
                                <TD colspan=3 class="tr17 td109"><P class="p21 ft44">Medical and health care payments</P></TD>
                                <TD class="tr17 td8"><P class="p16 ft54">To be filed with</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td107"><P class="p11 ft55_1">#qGetSystemConfig.TIN#</P></TD>
                                <TD class="tr24 td19"><P class="p11 ft55_1">#qForm1099.irs_ein#</P></TD>
                                <TD class="tr24 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td84"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td8"><P class="p16 ft69">recipient's state</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td107"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td84"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft55">income tax return,</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td107"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr13 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr10 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr13 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr10 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft55">when required.</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr21 td111"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td102"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td103"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td158"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td94"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td80"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td96"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td106"><P class="p7 ft34">&nbsp;</P></TD>
                                <TD class="tr21 td98"><P class="p7 ft34">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91"><P class="p10 ft46">RECIPIENT'S name</P></TD>
                                <TD class="tr2 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">7</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Nonemployee compensation</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">8</P></TD>
                                <TD colspan=3 class="tr2 td109"><P class="p21 ft44">Substitute payments in lieu of</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91" colspan=3><P class="p11 ft55_1">#qForm1099.CarrierName#</P></TD>
                                <TD class="tr3 td157"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 class="tr3 td99"><P class="p20 ft47">dividends or interest</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr6 td91"><P class="p10 ft46">Street address (including apt. no.)</P></TD>
                                <TD class="tr6 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr27 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr27 td94"><P class="p11 ft55_1">#NumberFormat(qForm1099.TotalCarrierCharges, '0.00')#</P></TD>
                                <TD class="tr27 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr27 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr27 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr27 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr6 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91" colspan=3><P class="p11 ft55_1">#qForm1099.Address#</P></TD>
                                <TD class="tr2 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">9</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Payer made direct sales of</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">10</P></TD>
                                <TD colspan=2 class="tr2 td99"><P class="p21 ft46">Crop insurance proceeds</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td19"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td20"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td157"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p25 ft47">$5,000 or more of consumer</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td110"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=4 rowspan=2 class="tr28 td83"><P class="p10 ft46">City or town, state or province, country, and ZIP or foreign postal code</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p25 ft47">products to a buyer</P></TD>
                                <TD rowspan=2 class="tr4 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr3 td110"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td93"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td94"><P class="p25 ft46">(recipient) for resale &##9658</P></TD>
                                <TD class="tr24 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91" colspan=3><P class="p11 ft55_1">#qForm1099.City#,#trim(qForm1099.stateCode)# #qForm1099.ZipCode#</P></TD>
                                <TD class="tr2 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">11</P></TD>
                                <TD class="tr2 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">12</P></TD>
                                <TD class="tr2 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr0 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr0 td160"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td93"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td79"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=2 class="tr0 td113"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr0 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91"><P class="p10 ft46">Account number (see instructions)</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td114"><P class="p21 ft46">FATCA filing</P></TD>
                                <TD class="tr2 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td84"><P class="p28 ft45">13</P></TD>
                                <TD class="tr2 td85"><P class="p25 ft46">Excess golden parachute</P></TD>
                                <TD class="tr2 td87"><P class="p16 ft45">14</P></TD>
                                <TD colspan=2 class="tr2 td99"><P class="p21 ft46">Gross proceeds paid to an</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td114"><P class="p21 ft47">requirement</P></TD>
                                <TD class="tr3 td157"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td84"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td85"><P class="p20 ft47">payments</P></TD>
                                <TD class="tr3 td87"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 class="tr3 td99"><P class="p21 ft47">attorney</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr4 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td115"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td158"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr4 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td79"><P class="p16 ft43">$</P></TD>
                                <TD class="tr4 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td107"><P class="p21 ft46"><SPAN class="ft45">15a </SPAN>Section 409A deferrals</P></TD>
                                <TD colspan=3 class="tr2 td159"><P class="p20 ft46"><SPAN class="ft45">15b </SPAN>Section 409A income</P></TD>
                                <TD colspan=2 class="tr2 td116"><P class="p20 ft46"><SPAN class="ft45">16 </SPAN>State tax withheld</P></TD>
                                <TD colspan=3 class="tr2 td117"><P class="p20 ft46"><SPAN class="ft45">17 </SPAN>State/Payer's state no.</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p23 ft46"><SPAN class="ft45">18 </SPAN>State income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td107"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td157"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td84"><P class="p28 ft43">$</P></TD>
                                <TD class="tr11 td85"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td110"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td8"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td111"><P class="p10 ft43">$</P></TD>
                                <TD class="tr7 td102"><P class="p9 ft43">$</P></TD>
                                <TD class="tr7 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td158"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td93"><P class="p28 ft43">$</P></TD>
                                <TD class="tr7 td94"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td79"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td80"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td98"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr14 td118"><P class="p25 ft53"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr14 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=4 class="tr14 td119"><P class="p31 ft46">www.irs.gov/Form1099MISC</P></TD>
                                <TD class="tr14 td87"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=4 class="tr14 td120"><P class="p16 ft44">Department of the Treasury - Internal Revenue Service</P></TD>
                            </TR>
                        </TABLE>
                    </DIV>
                    <P style="page-break-before: always"></P>
                    </cfif>
                    <cfif url.copy eq 'CopyC'>
                    <DIV id="page_7">
                        <DIV id="p7dimg1">
                            <IMG src="data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAGvAgcDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD0PwX4L8K3XgXw9cXHhrRpp5dMtnkkksImZ2MSkkkrkknnNSeJPCfhvTNPs7yw8P6VaXUeq6dsmgso43XN5CDhgMjIJH41J4a1DWtG8K6Rpdx4P1lp7Kyht5GjnsipZECkjNwDjI9BUmsXer63bWtlH4V1W2/4mFnM8081psRI7mORids7N91D0BoA7CiiigAooooAKKKKACuX8X2FnqeoeFrO/tILu1k1V98M8YkRsWdyRlTwcEA/hXUVz/ieK9+06De2WnT3/wBh1BppoYHjV9htp48jzHVT80i96AD/AIQTwf8A9Cpof/guh/8Aiar+ELCz0zUPFNnYWkFpax6qmyGCMRoubO2Jwo4GSSfxqx/wkOqf9CZrn/f6y/8AkijwxFe/adevb3Tp7D7dqCzQwzvGz7BbQR5Pluyj5o270AdBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQBzfjmCG68Nx29xFHNBLqenpJHIoZXU3kIIIPBBHGKk/4QTwf/wBCpof/AILof/iaueINKm1nSfslvcx2063FvcRyyRGVQ0UySgFQykglMdR1qn9j8Yf9B3Q//BNN/wDJVAEfgaCG18NyW9vFHDBFqeoJHHGoVUUXkwAAHAAHGK6Ss/RdM/sjTBambzpGlluJZAu0NJLI0j7VycLudsAkkDAJJ5OhQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUVj+JdWvNF0yK6srKC7ke7gtjHNcmEDzZFjVtwR+jOuRjpk9Rg1/tnjD/oBaH/AODmb/5FoA6Cis/QtT/tvw9pmreT5P260iufK3btm9A23OBnGcZwK0KACiiigArD8aTzWvgXxDcW8skM8WmXLxyRsVZGETEEEcgg85rcrL8S6bNrPhXV9Lt2jWe9spreNpCQoZ0KgnAJxk+hoAp/8Ibpf/P1rn/g9vf/AI9UfhSI2t54jsluLuaC11NUh+1XMk7IptbdyA0jM2NzscZ7mpPtnjD/AKAWh/8Ag5m/+RasaDp95aNqd3fiCO61G7Fy8MEhkSLEUcQUOVUtkRBs7RjdjnGSAbFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFAHL+Pr+z0/w/ay3t3BbRnVdPw80gQHbdxO3J9FVmPoFJ6CrH/Cd+D/APoa9D/8GMP/AMVXQUUAc/4E/wCSeeGv+wVa/wDopa6CiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKK8/wD+F2/Dz/oYf/JK4/8AjdH/AAu34ef9DD/5JXH/AMboA9AorP0TW9O8R6PBq2k3H2ixn3eXLsZN21ip4YAjkEciuP8A+F2/Dz/oYf8AySuP/jdAHoFFef8A/C7fh5/0MP8A5JXH/wAbrsNE1vTvEejwatpNx9osZ93ly7GTdtYqeGAI5BHIoA0KK8//AOF2/Dz/AKGH/wAkrj/43R/wu34ef9DD/wCSVx/8boA9AorP0TW9O8R6PBq2k3H2ixn3eXLsZN21ip4YAjkEciuP/wCF2/Dz/oYf/JK4/wDjdAHoFFef/wDC7fh5/wBDD/5JXH/xuuw0TW9O8R6PBq2k3H2ixn3eXLsZN21ip4YAjkEcigDQorz/AP4Xb8PP+hh/8krj/wCN0f8AC7fh5/0MP/klcf8AxugD0Cis/RNb07xHo8GraTcfaLGfd5cuxk3bWKnhgCOQRyK4/wD4Xb8PP+hh/wDJK4/+N0AegUV5/wD8Lt+Hn/Qw/wDklcf/ABuj/hdvw8/6GH/ySuP/AI3QB6BRXn//AAu34ef9DD/5JXH/AMbrsNb1vTvDmjz6tq1x9nsYNvmS7GfbuYKOFBJ5IHAoA0KK8/8A+F2/Dz/oYf8AySuP/jdH/C7fh5/0MP8A5JXH/wAboA9AorP1vW9O8OaPPq2rXH2exg2+ZLsZ9u5go4UEnkgcCuP/AOF2/Dz/AKGH/wAkrj/43QB6BRXn/wDwu34ef9DD/wCSVx/8brsNb1vTvDmjz6tq1x9nsYNvmS7GfbuYKOFBJ5IHAoA0KK8//wCF2/Dz/oYf/JK4/wDjdH/C7fh5/wBDD/5JXH/xugD0Cis/W9b07w5o8+ratcfZ7GDb5kuxn27mCjhQSeSBwK4//hdvw8/6GH/ySuP/AI3QB6BRXn//AAu34ef9DD/5JXH/AMbrsNb1vTvDmjz6tq1x9nsYNvmS7GfbuYKOFBJ5IHAoA0KK8/8A+F2/Dz/oYf8AySuP/jdH/C7fh5/0MP8A5JXH/wAboA9Aorz/AP4Xb8PP+hh/8krj/wCN1YsPi/4E1PUbaws9d8y6upUhhT7JONzsQFGSmBkkdaAO4orH8SeKdG8I6dHf65efZLWSUQq/lPJlyCQMICein8q5f/hdvw8/6GH/AMkrj/43QB6BRXD2Hxf8CanqNtYWeu+ZdXUqQwp9knG52ICjJTAySOtdB4k8U6N4R06O/wBcvPslrJKIVfynky5BIGEBPRT+VAGxRXn/APwu34ef9DD/AOSVx/8AG6sWHxf8CanqNtYWeu+ZdXUqQwp9knG52ICjJTAySOtAHcUVj+JPFOjeEdOjv9cvPslrJKIVfynky5BIGEBPRT+Vcv8A8Lt+Hn/Qw/8Aklcf/G6APQKK4ew+L/gTU9RtrCz13zLq6lSGFPsk43OxAUZKYGSR1roPEninRvCOnR3+uXn2S1klEKv5TyZcgkDCAnop/KgDYorz/wD4Xb8PP+hh/wDJK4/+N0UAf//Z" id="p7img1">
                        </DIV>
                        <TABLE cellpadding=0 cellspacing=0 class="t1">
                            <TR>
                                <TD class="tr0 td76"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=3 class="tr0 td161"><P class="p8 ft43">VOID</P></TD>
                                <TD colspan=2 class="tr0 td162"><P class="p9 ft43">CORRECTED</P></TD>
                                <TD class="tr0 td163"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=5 rowspan=2 class="tr17 td83"><P class="p10 ft44">PAYER'S name, street address, city or town, state or province, country, ZIP</P></TD>
                                <TD class="tr2 td116"><P class="p11 ft46"><SPAN class="ft45">1 </SPAN>Rents</P></TD>
                                <TD class="tr2 td86"><P class="p12 ft46">OMB No. <NOBR>1545-0115</NOBR></P></TD>
                                <TD class="tr2 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr12 td116"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td86"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td81"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td82"><P class="p7 ft24">&nbsp;</P></TD>
                                <TD class="tr12 td8"><P class="p7 ft24">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=4 class="tr3 td164"><P class="p10 ft47">or foreign postal code, and telephone no.</P></TD>
                                <TD class="tr3 td165"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td116"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD rowspan=3 class="tr25 td86"><P class="p12 ft49">#left(url.year,2)#<SPAN class="ft48">#right(url.year,2)#</SPAN></P></TD>
                                <TD class="tr3 td81"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD colspan=2 rowspan=2 class="tr8 td35"><P class="p16 ft50">Miscellaneous</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr13 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.companyName#</P></TD>
                                <TD class="tr13 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr1 td166"><P class="p60 ft43">$</P></TD>
                                <TD class="tr13 td81"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.address#</P></TD>
                                <TD class="tr7 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td116"><P class="p11 ft46"><SPAN class="ft45">2 </SPAN>Royalties</P></TD>
                                <TD class="tr7 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td82"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td8"><P class="p14 ft51">Income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr8 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.address2#</P></TD>
                                <TD class="tr8 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td166"><P class="p60 ft43">$</P></TD>
                                <TD class="tr9 td95"><P class="p12 ft52"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr9 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td97"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr9 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td91" colspan=4><P class="p11 ft55_1">#qGetCompanyInformation.city#,#qGetCompanyInformation.state# #qGetCompanyInformation.zipcode#</P></TD>
                                <TD class="tr10 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td116"><P class="p11 ft46"><SPAN class="ft45">3 </SPAN>Other income</P></TD>
                                <TD colspan=2 class="tr10 td117"><P class="p15 ft44"><SPAN class="ft57">4 </SPAN>Federal income tax withheld</P></TD>
                                <TD class="tr10 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft70">Copy C</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td102"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td167"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td168"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td166"><P class="p60 ft43">$</P></TD>
                                <TD class="tr7 td163"><P class="p38 ft43">$</P></TD>
                                <TD class="tr7 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td8"><P class="p16 ft54">For Payer</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td107"><P class="p10 ft46">PAYER'S TIN</P></TD>
                                <TD colspan=3 class="tr2 td35"><P class="p9 ft46">RECIPIENT'S TIN</P></TD>
                                <TD class="tr2 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td116"><P class="p11 ft46"><SPAN class="ft45">5 </SPAN>Fishing boat proceeds</P></TD>
                                <TD colspan=3 class="tr2 td169"><P class="p15 ft44"><SPAN class="ft57">6 </SPAN>Medical and health care payments</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr29 td111"><P class="p11 ft55_1">#qGetSystemConfig.TIN#</P></TD>
                                <TD class="tr29 td102"><P class="p11 ft55_1">#qForm1099.irs_ein#</P></TD>
                                <TD class="tr29 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td167"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td168"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td166"><P class="p60 ft43">$</P></TD>
                                <TD class="tr29 td163"><P class="p38 ft43">$</P></TD>
                                <TD class="tr29 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr29 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91"><P class="p10 ft46">RECIPIENT'S name</P></TD>
                                <TD class="tr2 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td116"><P class="p11 ft44"><SPAN class="ft57">7 </SPAN>Nonemployee compensation</P></TD>
                                <TD colspan=3 class="tr2 td169"><P class="p15 ft44"><SPAN class="ft57">8 </SPAN>Substitute payments in lieu of</P></TD>
                                <TD rowspan=2 class="tr20 td8"><P class="p16 ft43">For Privacy Act</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr19 td91" colspan=4><P class="p11 ft55_1">#qForm1099.CarrierName#</P></TD>
                                <TD class="tr19 td165"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD class="tr19 td116"><P class="p7 ft38">&nbsp;</P></TD>
                                <TD colspan=2 class="tr19 td117"><P class="p17 ft60">dividends or interest</P></TD>
                                <TD class="tr19 td100"><P class="p7 ft38">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td91"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td116"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td170"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft62">and Paperwork</P></TD>
                            </TR>
                            <TR>
                                <TD rowspan=2 class="tr30 td91"><P class="p10 ft46">Street address (including apt. no.)</P></TD>
                                <TD class="tr17 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr31 td166"><P class="p11 ft55_1">$#NumberFormat(qForm1099.TotalCarrierCharges, '0.00')#</P></TD>
                                <TD rowspan=2 class="tr31 td163"><P class="p38 ft43">$</P></TD>
                                <TD class="tr17 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td8"><P class="p16 ft71">Reduction Act</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td8"><P class="p16 ft72">Notice, see the</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr10 td91" colspan=4><P class="p7 ft8">&nbsp;</P><P class="p11 ft55_1">#qForm1099.Address#</P></TD>
                                <TD class="tr10 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td116"><P class="p11 ft46"><SPAN class="ft45">9 </SPAN>Payer made direct sales of</P></TD>
                                <TD colspan=2 class="tr10 td117"><P class="p20 ft46"><SPAN class="ft45">10 </SPAN>Crop insurance proceeds</P></TD>
                                <TD class="tr10 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td8"><P class="p16 ft70">2018 General</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr22 td91"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td19"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td20"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td21"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td165"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td116"><P class="p19 ft73">$5,000 or more of consumer</P></TD>
                                <TD class="tr22 td170"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td81"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td100"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD rowspan=2 class="tr11 td8"><P class="p16 ft53">Instructions for</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr22 td91"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td19"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td20"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td21"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td165"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td116"><P class="p19 ft73">products to a buyer</P></TD>
                                <TD rowspan=2 class="tr5 td163"><P class="p38 ft43">$</P></TD>
                                <TD class="tr22 td81"><P class="p7 ft37">&nbsp;</P></TD>
                                <TD class="tr22 td100"><P class="p7 ft37">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD colspan=5 class="tr17 td83"><P class="p10 ft46">City or town, state or province, country, and ZIP or foreign postal code</P></TD>
                                <TD class="tr10 td166"><P class="p19 ft46">(recipient) for resale &##9658</P></TD>
                                <TD class="tr10 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr10 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td8"><P class="p16 ft74">Certain</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr24 td91" colspan=4><P class="p11 ft55_1">#qForm1099.City#,#trim(qForm1099.stateCode)# #qForm1099.ZipCode#</P></TD>
                                <TD class="tr24 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td116"><P class="p60 ft45">11</P></TD>
                                <TD class="tr24 td170"><P class="p38 ft45">12</P></TD>
                                <TD class="tr24 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr24 td8"><P class="p26 ft58">Information</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr17 td91"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td116"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td170"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr17 td8"><P class="p16 ft74">Returns.</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr16 td101"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td102"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td103"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td167"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td168"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td166"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD colspan=2 class="tr16 td171"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr16 td106"><P class="p7 ft30">&nbsp;</P></TD>
                                <TD class="tr15 td8"><P class="p7 ft28">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td91"><P class="p10 ft46">Account number (see instructions)</P></TD>
                                <TD class="tr2 td90"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td114"><P class="p21 ft46">FATCA filing</P></TD>
                                <TD class="tr2 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td165"><P class="p7 ft46">2nd TIN not.</P></TD>
                                <TD class="tr2 td116"><P class="p20 ft46"><SPAN class="ft45">13 </SPAN>Excess golden parachute</P></TD>
                                <TD colspan=2 class="tr2 td117"><P class="p20 ft46"><SPAN class="ft45">14 </SPAN>Gross proceeds paid to an</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr3 td91"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td90"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td114"><P class="p21 ft47">requirement</P></TD>
                                <TD class="tr3 td21"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td165"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td116"><P class="p22 ft47">payments</P></TD>
                                <TD colspan=2 class="tr3 td117"><P class="p19 ft47">attorney</P></TD>
                                <TD class="tr3 td100"><P class="p7 ft14">&nbsp;</P></TD>
                                <TD class="tr3 td8"><P class="p7 ft14">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr4 td101"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td105"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td115"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td167"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td168"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td166"><P class="p60 ft43">$</P></TD>
                                <TD class="tr4 td163"><P class="p38 ft43">$</P></TD>
                                <TD class="tr4 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr4 td98"><P class="p7 ft8">&nbsp;</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr2 td107"><P class="p21 ft46"><SPAN class="ft45">15a </SPAN>Section 409A deferrals</P></TD>
                                <TD colspan=3 class="tr2 td35"><P class="p20 ft46"><SPAN class="ft45">15b </SPAN>Section 409A income</P></TD>
                                <TD class="tr2 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td116"><P class="p20 ft46"><SPAN class="ft45">16 </SPAN>State tax withheld</P></TD>
                                <TD colspan=2 class="tr2 td117"><P class="p20 ft46"><SPAN class="ft45">17 </SPAN>State/Payer's state no.</P></TD>
                                <TD class="tr2 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr2 td8"><P class="p23 ft46"><SPAN class="ft45">18 </SPAN>State income</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr11 td107"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td20"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td21"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td165"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td116"><P class="p60 ft43">$</P></TD>
                                <TD class="tr11 td170"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td81"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td100"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr11 td8"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr7 td111"><P class="p10 ft43">$</P></TD>
                                <TD class="tr7 td102"><P class="p9 ft43">$</P></TD>
                                <TD class="tr7 td103"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td167"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td168"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td166"><P class="p60 ft43">$</P></TD>
                                <TD class="tr7 td163"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td96"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td106"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD class="tr7 td98"><P class="p24 ft43">$</P></TD>
                            </TR>
                            <TR>
                                <TD class="tr14 td118"><P class="p25 ft53"><SPAN class="ft46">Form </SPAN><NOBR>1099-MISC</NOBR></P></TD>
                                <TD class="tr14 td19"><P class="p7 ft8">&nbsp;</P></TD>
                                <TD colspan=4 class="tr14 td119"><P class="p31 ft46">www.irs.gov/Form1099MISC</P></TD>
                                <TD colspan=4 class="tr14 td75"><P class="p16 ft46">Department of the Treasury - Internal Revenue Service</P></TD>
                            </TR>
                        </TABLE>
                    </DIV>
                    <P style="page-break-before: always">
                    <DIV id="page_8">
                        <DIV>
                            <DIV id="id8_1">
                                <P class="p27 ft75">Instructions for Payer</P>
                                <P class="p27 ft43">To complete Form <NOBR>1099-MISC,</NOBR> use:</P>
                                <P class="p61 ft71">&##9679The 2018 General Instructions for Certain Information Returns, and</SPAN></P>
                                <P class="p62 ft43">&##9679<SPAN class="ft77">The 2018 Instructions for Form </SPAN><NOBR>1099-MISC.</NOBR></P>
                                <P class="p63 ft71">To complete corrected Forms <NOBR>1099-MISC,</NOBR> see the 2018 General Instructions for Certain Information Returns.</P>
                                <P class="p64 ft71">To order these instructions and additional forms, go to <SPAN class="ft78">www.irs.gov/Form1099MISC</SPAN>.</P>
                                <P class="p65 ft71"><SPAN class="ft74">Caution: </SPAN>Because paper forms are scanned during processing, you cannot file Forms 1096, 1097, 1098, 1099, 3921, or 5498 that you print from the IRS website.</P>
                                <P class="p66 ft43"><SPAN class="ft53">Due dates. </SPAN>Furnish Copy B of this form to the recipient by January 31, 2019. The due date is extended to February 15, 2019, if you are reporting payments in box 8 or 14.</P>
                            </DIV>
                            <DIV id="id8_2">
                                <P class="p67 ft71">File Copy A of this form with the IRS by January 31, 2019, if you are reporting payments in</P>
                                <P class="p62 ft43">box 7. Otherwise, file by February 28, 2019, if you file on paper, or by April 1, 2019, if you file electronically. To file electronically, you must have software that generates a file according to the specifications in Pub. 1220. The IRS does not provide a <NOBR>fill-in</NOBR> form option for Copy A.</P>
                                <P class="p68 ft62"><SPAN class="ft70">Need help? </SPAN>If you have questions about reporting on Form <NOBR>1099-MISC,</NOBR> call the information reporting customer service site toll free at <NOBR>866-455-7438</NOBR> or</P>
                                <P class="p69 ft43"><NOBR>304-263-8700</NOBR> (not toll free). Persons with a hearing or speech disability with access to TTY/TDD equipment can call <NOBR>304-579-4827</NOBR> (not toll free).</P>
                            </DIV>
                        </DIV>
                    </DIV>
                    <P style="page-break-before: always"></P>
                    </cfif>
                </cfloop>
            </BODY>
        </HTML>
        </cfoutput>
    <!--- </cfdocument> --->
<cfelse>
    <cfoutput>No Records Found.</cfoutput>
</cfif>

