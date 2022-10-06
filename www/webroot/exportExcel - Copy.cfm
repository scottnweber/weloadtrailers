<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- Page: exportExcel.cfm --->
<!--- Purpose: 766: Feature Request- Excel Export Feature --->
<!--- Date: 2018-02-22 --->
<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfinvoke component="#variables.objloadGateway#" method="getLoadStatus" returnvariable="request.qLoadStatus" />
<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfset loadStatus=request.qGetSystemSetupOptions.ARANDAPEXPORTSTATUSID>
<cfoutput>
	<style type="text/css">
		.reportsSubHeading{
			border-bottom: 1px solid ##77463d !important;
			margin-bottom: 5px !important;
		}
	</style>
	<div class="white-con-area" style="height: 36px;background-color: ##82bbef;">
		<div style="float: left;"><h2 style="color:white;font-weight:bold;margin-left: 12px;">Export</h2></div>
	</div>
	<div style="clear:left"></div>

	<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid">
			<div class="form-con">
				<cfform name="frmExcelCustomersExport" action="index.cfm?event=ExportExcel:customers&#session.URLToken#" method="post">
					<fieldset>
						<h2 class="reportsSubHeading">Customers</h2>
						<div class="clear"></div>  
						<div style="margin-top:30px; margin-left: 118px;">
							<input id="excelSalesSummary" type="submit" name="excelSalesSummary" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="form-con">
				<cfform name="frmExcelCarrierDriverExport" action="index.cfm?event=ExportExcel:carriersDrivers&#session.URLToken#" method="post">
					<div class="clear"></div> 
					<fieldset>
						<h2 class="reportsSubHeading">Carriers/ Drivers</h2>
						<div class="clear"></div>  
						<div style="margin-top:30px; margin-left: 118px;">
							<input id="excelSalesDetails" type="submit" name="excelSalesDetails" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="clear"></div>
			<div class="form-con">
				<cfform name="frmExcelSalesSummaryExport" action="index.cfm?event=ExportExcel:salesSummary&#session.URLToken#" method="post">
					<fieldset style="padding-bottom: 10px;">
						<h2 class="reportsSubHeading">Sales Summary</h2>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Order Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" tabindex=4 name="summaryDateFrom" id="summaryDateFrom"  value="#dateformat(Now()-30,'mm/dd/yyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -54px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" tabindex=4 name="summaryDateTo" id="summaryDateTo"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<div style="margin-top: 30px;">
							<label>Status From</label>
				   			<select name="summaryStatusFrom" id="summaryStatusFrom">
								<cfloop query="request.qLoadStatus">
									<option value="#request.qLoadStatus.value#" <cfif loadStatus EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.Text#</option>
								</cfloop>
							</select>
							<label>Status To</label>
				   			<select name="summaryStatusTo" id="summaryStatusTo">
								<cfloop query="request.qLoadStatus">
									<option value="#request.qLoadStatus.value#" <cfif loadStatus EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.Text#</option>
								</cfloop>
							</select>
						</div>
						<div style="margin-top:30px; margin-left: 118px;">
							<input id="excelSalesSummary" type="submit" name="excelSalesSummary" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="form-con">
				<cfform name="frmExcelSalesDetailExport" action="index.cfm?event=ExportExcel:salesDetail&#session.URLToken#" method="post">
					<div class="clear"></div> 
					<fieldset>
						<h2 class="reportsSubHeading">Sales Detail</h2>
						<div class="clear"></div>  
						<label class="space_it" style="width: 103px;">Order Date From</label>
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" tabindex=4 name="detailDateFrom" id="detailDateFrom"  value="#dateformat(Now()-30,'mm/dd/yyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<label style="margin-left: -54px;width: 77px;">To</label> 
						<div style="position:relative;float:left;">
							<div style="float:left;">
								<input class="sm-input datefield" tabindex=4 name="detailDateTo" id="detailDateTo"  value="#dateformat(Now(),'mm/dd/yyy')#" validate="date" required="yes" message="Please enter a valid date" type="datefield" />
							</div>
						</div>
						<div style="margin-top: 30px;">
							<label>Status From</label>
				   			<select name="detailStatusFrom" id="detailStatusFrom">
								<cfloop query="request.qLoadStatus">
									<option value="#request.qLoadStatus.value#" <cfif loadStatus EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.Text#</option>
								</cfloop>
							</select>
							<label>Status To</label>
				   			<select name="detailStatusTo" id="detailStatusTo">
								<cfloop query="request.qLoadStatus">
									<option value="#request.qLoadStatus.value#" <cfif loadStatus EQ  request.qLoadStatus.value>selected="selected"</cfif>>#request.qLoadStatus.Text#</option>
								</cfloop>
							</select>
						</div>
						<div style="margin-top:30px; margin-left: 118px;">
							<input id="excelSalesDetails" type="submit" name="excelSalesDetails" class="bttn tooltip" value="Export" style="width:95px;"/>
						</div>
					</fieldset>
				</cfform>
			</div>
			<div class="clear"></div>
		</div>
		<div class="white-bot"></div>
	</div>

	<script type="text/javascript">
		$(document).ready(function(){
			$( "[type='datefield']" ).datepicker({
			  dateFormat: "mm/dd/yy",
			  showOn: "button",
			  buttonImage: "images/DateChooser.png",
			  buttonImageOnly: true
			});
		});	
	</script>
</cfoutput>