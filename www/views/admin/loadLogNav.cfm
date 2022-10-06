<cfparam name="event" default="customer">
<cfoutput>
<style>
	.below-navleft{
		width:720px;
	}
	.below-navleft ul li a {
		padding: 0 7px 0 7px;
	}
	.below-navright{
		width:200px;
	}
	.nav-with-sub-menu .li-has-sub-menu {
	    float: left;
	    display: block;
	    cursor: pointer;
	}
	.nav-with-sub-menu .li-has-sub-menu a.main-menu{
		padding: 0 20px 0 20px;
	    display: block;
	    text-decoration: none;
	    color: ##c1d5ed;
	    background: none;
	    line-height: 22px;
	    float: left;
	    
	}

	.nav-with-sub-menu .li-has-sub-menu a.main-menu.active{
		text-decoration: none;
	    color: ##ffffff;
	    background: ##8abd32;
	}
	.nav-with-sub-menu .li-has-sub-menu a.main-menu:hover{
		text-decoration: none;
	    color: ##ffffff;
	    background: ##8abd32;
	}
	.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu{
		position: absolute;
		display:none;
		margin-top: 22px;
		background: ##283d50;
	}

	.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li{
		float: none;
		width: 120px;
	}
	.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li a{
		padding: 0 20px 0 20px;
	    text-decoration: none;
	    color: ##c1d5ed;
	    background: none;
	    line-height: 22px;
	    //padding-top: 5px;
		//padding-bottom: 5px;
		width:100%;
	}
	.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li:hover{
		text-decoration: none;
	    color: ##ffffff;
	    background: ##8abd32;
	}
	.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li a:hover{
		text-decoration: none;
	    color: ##ffffff;
	}

</style>
<script>
	$(document).ready(function(){
		$('.li-has-sub-menu').mouseover(function(){
			if(!$(this).find('.ul-sub-menu').is(":visible")){
				$(this).find('.ul-sub-menu').show();
			}
		})
		$('.li-has-sub-menu').mouseleave(function(){
			if($(this).find('.ul-sub-menu').is(":visible")){
				$(this).find('.ul-sub-menu').hide();
			}
		});

		$('.ul-sub-menu li').click(function(){
			location.href = $( this ).find( "a" ).attr('href');
		})


		$('.ul-sub-menu li').mouseover(function(){
			$( this ).find( "a" ).css('color','##ffffff');
		})
		$('.ul-sub-menu li').mouseleave(function(){
			$( this ).find( "a" ).css('color','##c1d5ed');
		})

	});
</script>
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<div class="below-navleft nav-with-sub-menu" style="width: 890px;">
	<ul>
		<li><a href="index.cfm?event=loadLogs&#session.URLToken#" <cfif event is 'loadLogs' and not structKeyExists(url,'comdata')> class="active" </cfif>>Load Logs</a></li>
		<li><a href="index.cfm?event=EDILog&#session.URLToken#" <cfif event is 'EDILog'> class="active" </cfif>>EDI Log</a></li>
		<li><a href="index.cfm?event=Project44Log&#session.URLToken#" <cfif event is 'Project44Log'> class="active" </cfif>>Project44 Log</a></li>
		<cfif len(trim(request.qGetSystemSetupOptions.ComDataCustomerID))>
			<li><a href="index.cfm?event=loadLogs&#session.URLToken#&comdata=1" <cfif event is 'loadLogs' and structKeyExists(url,'comdata')> class="active" </cfif>>ComData Logs</a></li>
		</cfif>
		<li><a href="index.cfm?event=EmailLog&#session.URLToken#" <cfif event is 'EmailLog'> class="active" </cfif>>Email Log</a></li>
		<li><a href="index.cfm?event=TextLog&#session.URLToken#" <cfif event is 'TextLog'> class="active" </cfif>>Text Log</a></li>
		<li><a href="index.cfm?event=EdispatchLog&#session.URLToken#" <cfif event is 'EdispatchLog'> class="active" </cfif>>E-Dispatch Log</a></li>


		<li class="li-has-sub-menu">
			<a  class="main-menu <cfif listFindNoCase("CsvImportLog,CarrierCsvImportLog,CustomerCsvImportLog,EquipmentCsvImportLog", event)> active </cfif>" >CSV Import Log</a>
			<ul class="ul-sub-menu" style="z-index: 99;">
				<li><a href="index.cfm?event=CsvImportLog&#Session.URLToken#">Loads</a></li>
				<li><a href="index.cfm?event=CarrierCsvImportLog&#Session.URLToken#"><cfif  request.qGetSystemSetupOptions.freightBroker EQ 1>Carriers<cfelseif request.qGetSystemSetupOptions.freightBroker EQ 2>Carriers/Drivers<cfelse>Drivers</cfif></a></li>
				<li><a href="index.cfm?event=CustomerCsvImportLog&#Session.URLToken#">Customers</a></li>
				<li><a href="index.cfm?event=EquipmentCsvImportLog&#Session.URLToken#">Equipments</a></li>
			</ul>
		</li>


		<li><a href="index.cfm?event=BulkDeleteLog&#session.URLToken#" <cfif event is 'BulkDeleteLog'> class="active" </cfif>>Bulk Delete Log</a></li>
	</ul>
<div class="clear"></div>
</div>
<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
<div style="float:right;margin-top: -57px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
</cfoutput>