<cfset Secret = application.dsn>
<cfset TheKey = 'NAMASKARAM'>
<cfset Encrypted = Encrypt(Secret, TheKey)>
<cfset dsn = ToBase64(Encrypted)>
<cfsilent>
	<cfinvoke component="#variables.objLoadGateway#" method="getLMASystemConfig" returnvariable="qLMASystemConfig" />
	<cfset FiscalYear = qLMASystemConfig['Fiscal Year']>
	<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
	<cfinvoke component="#variables.objLoadGateway#" method="getDeptList" returnvariable="qDeptList" />
</cfsilent>

<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
		.white-mid div.form-con fieldset label{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset input.sm-input{
			font-size: 12px;
		}
		.white-mid form div.form-con fieldset select{
			font-size: 12px;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Print Income Statement</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
	    <div class="white-mid" style="background-color: #request.qGetSystemSetupOptions.BackgroundColorForContentAccounting# !important;">
			<cfform name="frmCommissionReport" action="##" method="post">
				<div class="form-con">
					<fieldset style="padding:5px;float:left;width: 60%;">
						<h2 class="reportsSubHeading">Which Month?</h2>
                        <div>
                        	<label style="width:70px;">Period: </label>
                            <input class="sm-input datefield" tabindex=4 name="period" id="period"  value="#DateFormat(now(),"mm/yyyy")#" validate="date" required="yes" message="Please enter a valid date" type="datefield" style="width: 60px;text-align: right;"/>
                        </div>
                        <div class="clear"></div>
                        <div>
                        	<label style="width:70px;">Fiscal Year: </label>
                            <input class="sm-input" tabindex=4 name="FiscalYear" id="FiscalYear"  value="#DateFormat(FiscalYear,"mm/dd/yyyy")#" readonly style="width: 60px;"/>
                        </div>
                        <div class="clear"></div>
                        <h2 class="reportsSubHeading">Department</h2>
                        <div>
                        	<label style="width:70px;">Summarize Depts?</label>
                           	<input type="checkbox" name="SummarizeDepts" id="SummarizeDepts" style="float: left;margin-top: 10px;width: 15px;">
                        </div>
                        <div class="clear"></div>
                        <div>
                        	<label style="width:70px;">Dept Filter?</label>
                           	<input type="checkbox" class="DeptFilter" name="DeptFilter" id="DeptFilter" style="float: left;width: 15px;">
                        </div>
                        <div class="clear"></div>
                        <div>
                        	<label style="width:70px;">From Dept: </label>
                    		<select style="width: 55px;background-color: rgb(220 241 240);" name="FromDept" id="FromDept" class="DeptFilter Dept" disabled>
                    			<option value=""></option>
                    			<cfloop query="qDeptList">
                    				<option value="#qDeptList.Dept#">#qDeptList.Dept#</option>
                    			</cfloop>
                    		</select>
                        </div>
                        <div>
                        	<label style="width:30px;">To: </label>
                        	<select style="width: 55px;background-color: rgb(220 241 240);" name="ToDept" id="ToDept" class="DeptFilter Dept" disabled>
                        		<option value=""></option>
                    			<cfloop query="qDeptList">
                    				<option value="#qDeptList.Dept#">#qDeptList.Dept#</option>
                    			</cfloop>
                    		</select>
                        </div>
					</fieldset>
				</div>
				<div class="form-con">
					<div class="right">
			        	<div>
							<input id="sReport" type="button" name="viewReport" class="bttn tooltip" value="Print" style="width:95px;height: 40px;background-size: contain;"/>
			        	</div>
				    </div>
				</div>
	   			<div class="clear"></div>
	 		</cfform>
	    </div>
		<div class="white-bot"></div>
	</div>
	<script type="text/javascript">
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true,
                showButtonPanel: true,
                todayBtn:'linked',
                onClose: function ()
                {
                    this.focus();
                }
			});
			$.datepicker._gotoToday = function(id) { 
                $(id).datepicker('setDate', new Date()).datepicker('hide').blur().change(); 
            };

			$('##SummarizeDepts').click(function(){	
				if($(this).prop("checked")){
					$('##DeptFilter').attr('checked', false);
					$('##FromDept').val('');
					$('##ToDept').val('');
					$('.DeptFilter').prop( "disabled", true );
					$('.DeptFilter').css( "background", "rgb(220 241 240)" );
				}
				else{
					$('.DeptFilter').prop( "disabled", false );
					$('.DeptFilter').css( "background", "##ffffff" );
					$('##FromDept,##ToDept').prop( "disabled", true ).css( "background", "rgb(220 241 240)" );

				}
			})

			$('##DeptFilter').click(function(){	
				if($(this).prop("checked")){
					$('##SummarizeDepts').prop( "disabled", true );
					$('##SummarizeDepts').css( "background", "rgb(220 241 240)" );
					$('##FromDept,##ToDept').prop( "disabled", false ).css( "background", "##ffffff");
				}
				else{
					$('##SummarizeDepts').prop( "disabled", false );
					$('##SummarizeDepts').css( "background", "##ffffff" );
					$('##FromDept,##ToDept').prop( "disabled", true );
				}
			})

			$('##sReport').click(function(){	
			 	//if(checkdate()){
					var url = "../reports/LMAPrintIncomeStatement.cfm?dsn=#dsn#";
					url += "&period="+$("##period"). val();
					if($('##SummarizeDepts').prop("checked")){
			 			url += "&SummarizeDepts=1";	
			 		}

			 		if($('##DeptFilter').prop("checked")){
			 			url += "&DeptFilter=1";	
			 			var FromDept = $('##FromDept').val();
			 			var ToDept = $('##ToDept').val();
			 			url += "&FromDept="+FromDept;	
			 			url += "&ToDept="+ToDept;	
			 		}
					url += '&#session.URLToken#'
					window.open(url);
			    //}
			});
		});		

		function checkdate(){
			var reg =/((^(10|12|0?[13578])([/])(3[01]|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(11|0?[469])([/])(30|[12][0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(2[0-8]|1[0-9]|0?[1-9])([/])((1[8-9]\d{2})|([2-9]\d{3}))$)|(^(0?2)([/])(29)([/])([2468][048]00)$)|(^(0?2)([/])(29)([/])([3579][26]00)$)|(^(0?2)([/])(29)([/])([1][89][0][48])$)|(^(0?2)([/])(29)([/])([2-9][0-9][0][48])$)|(^(0?2)([/])(29)([/])([1][89][2468][048])$)|(^(0?2)([/])(29)([/])([2-9][0-9][2468][048])$)|(^(0?2)([/])(29)([/])([1][89][13579][26])$)|(^(0?2)([/])(29)([/])([2-9][0-9][13579][26])$))/;
			    
	    	if($('##period').val().length){
	    		if(!$('##period').val().match(reg)){
	    			alert('Please enter a valid date.');
	    			$('##period').focus();
	    			$('##period').val('');
	    			return false;
	    		}
	    	}	
	
            return true;
		}
		
	</script>
</cfoutput>