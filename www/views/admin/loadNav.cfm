<cfparam name="event" default="customer">
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
<cfif not structKeyExists(session, "empid")>
	<cflocation url="index.cfm?event=logout:process">
</cfif>
<cfinvoke component="#variables.objloadGateway#" method="getcurAgentdetails" returnvariable="request.qAgentdetails" employeID="#session.empid#" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qSystemOptions" />
<cfoutput>

	<style>
		.jconfirm-scrollpane{
    		margin-left: 25%;
    		width:32% !important;
		}
		.dialog{
			width: 325px;
		    //height: 250px;
		    position: absolute;
		    background-color: ##ffffff;
		    left: 25%;
		    z-index: 9999;
		    border-radius: 5px;
		    top:25%;
		    display:none;
		    box-shadow: 0 2px 6px rgba(0,0,0,0.2);
		    //overflow: auto;
		}
		.dialogTitle{
			margin-top: 15px;
    		margin-left: 15px;
    		font:normal 11px/16px Arial, Helvetica, sans-serif;
    		font-size: 15px;
    		float:left;
		}
		.dialogContent{
			margin-top: 15px;
    		margin-left: 15px;
    		font:normal 11px/16px Arial, Helvetica, sans-serif;
    		margin-bottom: 10px;
    		max-height: 400px;
    		overflow: auto;
		}
		.below-navleft tr td a{
			padding-left: 6px;
		}
		.below-navleft{
			margin-bottom: 20px;
		}
		##loader_miles{
            position: fixed;
            top:40%;
            left:40%;
            z-index: 999;
            display: none;
        }
        ##loadingmsg_miles{
            font-weight: bold;
            text-align: center;
            margin-top: 1px;
            background-color: ##fff;
        }
		.nav-with-sub-menu{
			position:relative;
			width: 69px;
		    float: left;
		    display: block;
		    padding: 0;
		    margin: 0;
		    margin-top: 0;
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
			width:163px;
		}

		.nav-with-sub-menu .li-has-sub-menu .ul-sub-menu li a{
			display:block;
			padding: 0 0 0 5px;
		    text-decoration: none;
		    color: ##c1d5ed;
		    background: none;
		    line-height: 22px;
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
		.li-has-sub-menu{
			background-image:  url(images/subnav-libg.gif);background-repeat: no-repeat;background-position: right;
		}
		.li-has-sub-menu:last-child{
			background: none;
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
	<table class="below-navleft" style="border-collapse:collapse; border:none; width:890px;" border="0" cellpadding="0" cellspacing="0">
	<cfif structKeyExists(session, "currentusertype") AND session.currentusertype EQ "Administrator">
		<td>
			<a href="index.cfm?event=load&#session.URLToken#" <cfif (event is 'load' or event is 'addload:process' or event is 'myload' or event is 'myloadnew') AND NOT  structKeyExists(url, "Pending")> class="active" </cfif>>All Loads</a>
			</td>
			<td>
				<cfif request.qSystemOptions.LowVolumePlan EQ 1>
					<cfset addLoadUrl = "javascript:checkLoadLimit();">
				<cfelse>
					<cfset addLoadUrl = "index.cfm?event=addload&#session.URLToken#">
				</cfif>
				<a href="#addLoadUrl#" <cfif listFindNoCase("addload,BOLReport", event)> class="active" </cfif>>Add Load</a>
			</td>    
			<td>
				<a href="index.cfm?event=carrierquotes&#session.URLToken#" target="_blank"  <cfif event is 'carrierquotes'> class="active" </cfif>>Carrier Quotes</a>
			</td>       
			<td>
			<a href="index.cfm?event=quickRateAndMilesCalc&#session.URLToken#" <cfif event is 'quickRateAndMilesCalc'> class="active" </cfif>>Quick Miles</a>
			</td>
			
			<td>
			<a href="index.cfm?event=advancedsearch&#session.URLToken#" <cfif event is 'advancedsearch'> class="active"</cfif>>Advanced Search</a>
			</td>
			
			<td>
			<a href="index.cfm?event=unit&#session.URLToken#" <cfif event is 'unit' or event is 'addunit:process' or event is 'addunit'> class="active" </cfif>>Commodity Type</a>
			</td>
			
			<td>
			<a href="index.cfm?event=class&#session.URLToken#" <cfif event is 'class' or event is 'addclass:process' or event is 'addclass'> class="active" </cfif>> Commodity Class</a>
			</td>
			
			<td>
				<a href="index.cfm?event=EDILoads&#session.URLToken#" <cfif event is 'EDILoads'> class="active" </cfif>>EDI Loads</a>
			</td>
			<td>
			<a href="index.cfm?event=Factoring&#session.URLToken#" <cfif event is 'Factoring' or event is 'addFactoring'> class="active" </cfif>>Factoring</a>
			</td>
			<cfif ListContains(session.rightsList,'DeleteLoad',',') OR (structKeyExists(session, "currentusertype") and session.currentusertype EQ "Administrator")>
				<td>
					<a href="javascript:deleteLoad()">Delete Loads</a>
				</td>
			</cfif>
			<td>
				<div class="nav-with-sub-menu">
					<ul>
						<li class="li-has-sub-menu">
							<a href="" class="main-menu <cfif listFindNoCase("AIImport,UploadCustomerPayment", event)>active </cfif>">Import</a>
							<ul class="ul-sub-menu" style="z-index: 99; border:none;">
								<li style="background-image: none;width: 100%;"><a  href="index.cfm?event=AIImport&#session.URLToken#">Smart Load Import</a></li>
								<li style="width: 100%;"><a style="padding-right: 5px;" href="index.cfm?event=UploadCustomerPayment&#session.URLToken#">Customer Paid Loads Import</a></li>
							</ul>
						</li>
					</ul>
				</div>
			</td>
			<td>
			<a style="padding-right: 5px;" href="index.cfm?event=load&#session.URLToken#&Pending=1"  <cfif event is 'load' and structKeyExists(url, "Pending")> class="active" </cfif>>Pending</a>
			</td>
		</tr>
	<cfelse>
		<tr>
			<td>
				<cfif request.qSystemOptions.LowVolumePlan EQ 1>
					<cfset addLoadUrl = "javascript:checkLoadLimit();">
				<cfelse>
					<cfset addLoadUrl = "index.cfm?event=addcustomerload&#session.URLToken#">
				</cfif>
				<a href="index.cfm?event=addcustomerload&#session.URLToken#" <cfif event is 'addcustomerload'> class="active" </cfif>>Add Load</a>
			</td>  
		</tr>
	</cfif>
	</table>


<div class="below-navright" id="helpLink" style="padding-top: 4px;width: 30px;">
</div>
<cfif listFindNoCase("load,myLoad", event) and request.qSystemOptions.LowVolumePlan EQ 0>
	<div style="float: right;margin-right: -362px;margin-top: -33px;">
		<strong>Import Loads Via CSV:</strong><br>
	    <input type="file" id="importCSV"><br>
	    <a style="text-decoration: underline;" href="https://desk.zoho.com/portal/loadmanager/en/kb/articles/upload-record-to-load-manager" target="_blank">Instructions</a><br>
	    <a style="text-decoration: underline;" href="../../../LoadManagerAdmin/LoadsImportSampleFile.csv"  download>Download Sample File</a>
	</div>		
</cfif>
<cfif structKeyExists(session, "empid") and len(trim(session.empid))>
	<div style="float:right;margin-right: -100px;margin-top: -59px;"><a href="index.cfm?event=feedback&#Session.URLToken#"><img src="images/support.png" width="100px" border="0"></a></div>
</cfif>
<cfif structKeyExists(session, "currentusertype") AND session.currentusertype EQ "Administrator">
	<div style="float:right;margin-top: -77px;"><a href="javascript:void(0);" onclick="window.open('index.cfm?event=postNote&#session.URLToken#','Map','height=600,width=800');"><img src="images/postedNoteIcon.png" width="100px" border="0"></a></div>
</cfif>
<div class="dialog">
	<p class="dialogTitle"></p>
	<img width="10px" style="float:right;cursor: pointer;margin-right: 10px;margin-top: 5px;" src="images/close.gif" onClick="window.location.reload();">
	<div class="clear"></div> 
	<img class="dialogLoader" src="images/loadDelLoader.gif" width="100px" style="margin-left: 90px;">
	<p class="dialogContent"></p>
</div>
<div class="clear"></div> 
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.2/jquery-confirm.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.3.2/jquery-confirm.min.js"></script>
<script type="text/javascript">

	$(document).ready(function(){
		var backBtnClicked = 0;
		if (window.performance && window.performance.navigation.type == window.performance.navigation.TYPE_BACK_FORWARD) {
			var backBtnClicked = 1;
	    }
		<cfif structKeyExists(session, "LoadEmailUpdateMsg")>
			if(!backBtnClicked){
				alert('#session.LoadEmailUpdateMsg#');
			}
			<cfset structDelete(session, "LoadEmailUpdateMsg")>
		</cfif>
	})
	function checkLoadLimit(){
		$.ajax({
            type    : 'POST',
            url     : "ajax.cfm?event=ajxCheckLoadLmit",
            data    : {},
            beforeSend:function() {
            	$('.overlay').show();
            },
            success :function(LoadLimitReached){
            	if(LoadLimitReached==1){
            		$('.overlay').hide();
            		alert("Your plan has a limit of 30 loads per month. If you'd like to upgrade your account please login to your billing account and change your plan.");
            	}
            	else{
            		$('.overlay').hide();
            		location.href="index.cfm?event=addload&#session.URLToken#";
            	}
            }
        })
	}

	function deleteLoad(){
		$.confirm({
		    title: '<p style="color:##ba0000">Warning!</p>',
		    content: '<strong style="font-size:12px;">You will only be allowed to delete SPOT loads or CANCELLED loads. If you choose to delete loads, the results will be logged along with your user information. Once deleted these loads will be unrecoverable. Click OK to proceed to the next screen or click CANCEL to abort.</strong>',
		    buttons: {
		        confirm: {
		        	text: 'OK',
		        	action: function () {
        				$.confirm({
					    title: 'Select status',
					    content: '<select class="status" style="width:250px;padding:3px;"><cfloop query="#request.qLoadStatus#"><cfif listFindNoCase("0.1 SPOT,9. Cancelled", request.qLoadStatus.Text)> <option value="#request.qLoadStatus.value#">#request.qLoadStatus.StatusDescription#</option></cfif></cfloop></select>',
					    buttons: {
					        confirm: {
					        	text: 'DELETE LOADS',
					        	action: function () {
					        		var StatusTypeID = this.$content.find('.status').val();
					        		$.confirm({
									    title: '<p style="color:##008000">Confirm!</p>',
									    content: '<strong style="font-size:12px;">Are you sure?</strong>',
									    buttons: {
									        confirm: {
									        	text: 'OK',
									        	action: function () {
									        		var path = urlComponentPath+"loadgateway.cfc?method=getLoadsByStatus";
									        		$.ajax({
								                        type: "get",
								                        url: path,
								                        data: {StatusTypeID:StatusTypeID,dsn:'#application.dsn#',CompanyID:'#session.CompanyID#'},
								                        success: function(data){
								                            dataJson = jQuery.parseJSON(data);
								                            if(dataJson.length){
								                            	recursiveAjaxDeleteLoad(dataJson,0);
								                        	}
								                        	else{
								                        		$.confirm({
																    title: '',
																    content: '<strong style="font-size:12px;">No Loads found.</strong>',
																    buttons: {
																        confirm: {
																            text: 'OK',
																            btnClass: 'btn-blue',
																            keys: ['enter'],
																        }
																    }
																});
								                        	}
								                        }
								                    });
									        	}
									        },
									        cancel: {
									            btnClass: 'btn-blue',
									            keys: ['enter'],
									            action:function () {
									            	$.confirm({
												    title: '',
												    content: '<strong style="font-size:12px;">No Loads were deleted.</strong>',
												    buttons: {
												        confirm: {
												            text: 'OK',
												            btnClass: 'btn-blue',
												            keys: ['enter'],
												        }
												    }
												});
									            }
									        }
									    }
									});
					        	}
					        },
					        cancel: {
					            btnClass: 'btn-blue',
					            keys: ['enter'],
					            action:function () {
					            	$.confirm({
								    title: '',
								    content: '<strong style="font-size:12px;">No Loads were deleted.</strong>',
								    buttons: {
								        confirm: {
								            text: 'OK',
								            btnClass: 'btn-blue',
								            keys: ['enter'],
								        }
								    }
								});
					            }
					        }
					    }
					});
		        	}
		        },
		        cancel: {
		            btnClass: 'btn-blue',
		            keys: ['enter'],
		        }
		    }
		});
	}
	var delCount = 0;
	function recursiveAjaxDeleteLoad(dataJson,index){
		var nextIndx = index+1;
		var path = "ajax.cfm?event=ajxBulkDeleteLoad";
		var pathUnPost = urlComponentPath+"loadgateway.cfc?method=deleteLoadUnpost";
		$.ajax({
			type: "Post",
			url: pathUnPost,
			data:{
				loadid:dataJson[index].LOADID,dsn:'#application.dsn#',loadBoard123Usename:'#request.qAgentdetails.loadBoard123Usename#',loadBoard123Password:'#request.qAgentdetails.loadBoard123Password#',DirectFreightLoadboardUserName:'#request.qAgentdetails.DirectFreightLoadboardUserName#',DirectFreightLoadboardPassword:'#request.qAgentdetails.DirectFreightLoadboardPassword#',
					ITSUsername:'#request.qSystemOptions.ITSUsername#',ITSPassword:'#request.qSystemOptions.ITSPassword#',ITSIntegrationID:'#request.qAgentdetails.IntegrationID#',
					PEPsecretKey:'#request.qSystemOptions.PEPsecretKey#',PEPcustomerKey:'#request.qAgentdetails.PEPcustomerKey#',DirectFreightLoadboardUserName:'#request.qAgentdetails.DirectFreightLoadboardUserName#',DirectFreightLoadboardPassword:'#request.qAgentdetails.DirectFreightLoadboardPassword#'
				},
			success: function(res){
				if(res == 0){
					$('.dialogContent').prepend('<strong style="color:##ba0000">Unable to unpost Load##:'+dataJson[index].LOADNUMBER+'<strong><br>')
					if(nextIndx<dataJson.length){
		        		recursiveAjaxDeleteLoad(dataJson,nextIndx)
		        	}
		        	else{
		        		$('.dialogLoader').hide();
		        		if(delCount==1){
		        			$('.dialogTitle').html('<strong>1 Load Deleted.</strong>')
		        		}
		        		else{
		        			$('.dialogTitle').html('<strong>'+delCount+' Loads Deleted.</strong>')
		        		}
		        		delCount=0;
		        	}
				}
				else{
					$.ajax({
				        type: "Post",
				        url: path,
				        data: {
				            loadid:dataJson[index].LOADID,dsn:'#application.dsn#',empid:'#session.empid#',adminUserName:'#session.adminUserName#',bulkDelete:1,
				        },
				        success: function(result){
				        	$('.dialogContent').append('<strong>Deleted Load##:'+dataJson[index].LOADNUMBER+'<strong><br>')
				        	delCount++;
				        	if(nextIndx<dataJson.length){
				        		recursiveAjaxDeleteLoad(dataJson,nextIndx)
				        	}
				        	else{
				        		$('.dialogLoader').hide();
				        		if(delCount==1){
				        			$('.dialogTitle').html('<strong>1 Load Deleted.</strong>')
				        		}
				        		else{
				        			$('.dialogTitle').html('<strong>'+delCount+' Loads Deleted.</strong>')
				        		}
				        		delCount=0;
				        	}
				        },
				        error: function(result){
				        	$('.dialogContent').prepend('<strong style="color:##ba0000">Unable to delete Load##:'+dataJson[index].LOADNUMBER+'<strong><br>')
				        	if(nextIndx<dataJson.length){
				        		recursiveAjaxDeleteLoad(dataJson,nextIndx)
				        	}
				        	else{
				        		$('.dialogLoader').hide();
				        		if(delCount==1){
				        			$('.dialogTitle').html('<strong>1 Load Deleted.</strong>')
				        		}
				        		else{
				        			$('.dialogTitle').html('<strong>'+delCount+' Loads Deleted.</strong>')
				        		}
				        		delCount=0;
				        	}
				        	
				        },
				        beforeSend:function() {
				        	$('.dialog').show();
				        	$('.dialogTitle').html('<strong>Please wait. Deleting load ##'+dataJson[index].LOADNUMBER+'...</strong>')
				        	$('.overlay').show();
				        }

				    });
				}
			},
			beforeSend:function() {
	        	$('.dialog').show();
	        	$('.dialogTitle').html('<strong>Please wait. Unposting Load ##'+dataJson[index].LOADNUMBER+'...</strong>')
	        	$('.overlay').show();
	        },
	        error: function(result){
	        	$('.dialogContent').prepend('<strong style="color:##ba0000">Unable to unpost Load##:'+dataJson[index].LOADNUMBER+'<strong><br>')
	        	if(nextIndx<dataJson.length){
	        		recursiveAjaxDeleteLoad(dataJson,nextIndx)
	        	}
	        	else{
	        		$('.dialogLoader').hide();
	        		if(delCount==1){
	        			$('.dialogTitle').html('<strong>1 Load Deleted.</strong>')
	        		}
	        		else{
	        			$('.dialogTitle').html('<strong>'+delCount+' Loads Deleted.</strong>')
	        		}
	        		delCount=0;
	        	}
	        }

		})
	}
</script>
<div id="loader_miles">
    <img src="images/loadDelLoader.gif">
    <p id="loadingmsg_miles">Calculating miles. Please wait.</p>
</div>
</cfoutput>