<cfoutput>
<style>
    ##tabs1 .ui-tabs-active a{
        font-weight: bolder;font-size: 12px;padding-bottom: 4px;
    }
</style>
<div class="white-con-area">
    <div style="float: left;">
        <div id="tabs1" class="tabsload ui-tabs ui-widget ui-widget-content ui-corner-all">
            <ul class="ui-tabs-nav ui-helper-reset ui-helper-clearfix ui-widget-header ui-corner-all" style="height:27px;">
                <li class="ui-state-default ui-corner-top <cfif url.event eq 'QuickBooksExport'> ui-tabs-active ui-state-active </cfif>">
                    <a class="ui-tabs-anchor" href="index.cfm?event=QuickBooksExport&#Session.URLToken#">Invoice Export</a>
                </li>
                <li class="ui-state-default ui-corner-top <cfif url.event eq 'QuickBooksExportAP'> ui-tabs-active ui-state-active </cfif>">
                    <a class="ui-tabs-anchor" href="index.cfm?event=QuickBooksExportAP&#Session.URLToken#">Bills Export</a>
                </li>
                <li class="ui-state-default ui-corner-top <cfif url.event eq 'QuickBooksExportHistory'> ui-tabs-active ui-state-active </cfif>">
                    <a class="ui-tabs-anchor" href="index.cfm?event=QuickBooksExportHistory&#Session.URLToken#">Export History</a>
                </li>
                <li class="ui-state-default ui-corner-top <cfif url.event eq 'QBNotExported'> ui-tabs-active ui-state-active </cfif>">
                    <a class="ui-tabs-anchor" href="index.cfm?event=QBNotExported&#Session.URLToken#">Not Exported</a>
                </li>
            </ul>
        </div>
    </div>
</div>
<div style="clear:left"></div>
</cfoutput>