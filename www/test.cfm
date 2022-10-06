<!---<cfset LocalHost = CreateObject( "java", "java.net.InetAddress" ).getLocalHost() />
<cfset Mac = CreateObject( "java", "java.net.NetworkInterface" ).getByInetAddress( LocalHost ).getHardWareAddress() />
<cfset MacAddress = '' />
<cfloop from="1" to="#ArrayLen( Mac )#" index="Pair">
    <!--- Convert it to Hex, and only use the right two AFTER the conversion--->
    <cfset NewPair = Right( FormatBaseN( Mac[ Pair ], 16 ), 2 ) />

    <!--- If it's only one letter/string, pad it --->
    <cfset NewPair = Len( NewPair ) EQ 1 ? '0' & NewPair : NewPair />

    <!--- Append NewPair --->    
    <cfset MacAddress &= UCase( NewPair ) />

    <!--- Add the dash --->
    <cfif ArrayLen( Mac ) NEQ Pair>
        <cfset MacAddress &= '-' />
    </cfif>
</cfloop>--->
<cfif StructKeyExists(GetHttpRequestData().headers, "X-Forwarded-For") >
<cfset REQUEST.remoteAddress = Trim(ListFirst(GetHttpRequestData().headers["X-Forwarded-For"])) > <cfelse>
<cfset REQUEST.remoteAddress = CGI.REMOTE_ADDR >
</cfif>

<cfdump var="#GetHttpRequestData().headers#" />