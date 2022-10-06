<cfoutput>
	<style type="text/css">
		.brd-btm{
			border-bottom: groove 1px;
		}
	</style>
	<form method="post" action="index.cfm?event=CoveredLanes:Process&CarrierID=#url.CarrierID#">
		<div class="row">
			<div class="col-xs-12 col-lg-12">
				<h2 class="col-xs-12 col-lg-12 blueBg fs-22">COVERED LANES:</h2>
				<p>Please select the lanes that you can cover for us:</p>
			</div>
		</div>
		<div class="row">
			<div class="col-xs-12 col-lg-6">
				<h2 class="col-xs-12 col-lg-12 blueBg">UNITED STATUS</h2>

				<!--- ZONE 0 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone0">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone0">ZONE 0</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="CT" id="CT">
	  					<label class="form-check-label ZoneStateLabel" for="CT">Connecticut</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="ME" id="ME">
	  					<label class="form-check-label ZoneStateLabel" for="ME">Maine</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="MA" id="MA">
	  					<label class="form-check-label ZoneStateLabel" for="MA">Massachusetts</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="NH" id="NH">
	  					<label class="form-check-label ZoneStateLabel" for="NH">New&nbsp;Hampshire</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="NJ" id="NJ">
	  					<label class="form-check-label ZoneStateLabel" for="NJ">New Jersey</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="RI" id="RI">
	  					<label class="form-check-label ZoneStateLabel" for="RI">Rhode Island</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone0" type="checkbox" value="VT" id="VT">
	  					<label class="form-check-label ZoneStateLabel" for="VT">Vermont</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 0 --->

				<!--- ZONE 1 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone1">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone1">ZONE 1</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone1" type="checkbox" value="DE" id="DE">
	  					<label class="form-check-label ZoneStateLabel" for="DE">Delaware</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone1" type="checkbox" value="NY" id="NY">
	  					<label class="form-check-label ZoneStateLabel" for="NY">New York</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone1" type="checkbox" value="PA" id="PA">
	  					<label class="form-check-label ZoneStateLabel" for="PA">Pennsylvania</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 1 --->

				<!--- ZONE 2 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone2">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone2">ZONE 2</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone2" type="checkbox" value="MD" id="MD">
	  					<label class="form-check-label ZoneStateLabel" for="MD">Maryland</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone2" type="checkbox" value="NC" id="NC">
	  					<label class="form-check-label ZoneStateLabel" for="NC">North Carolina</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone2" type="checkbox" value="WV" id="WV">
	  					<label class="form-check-label ZoneStateLabel" for="WV">West Virginia</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone2" type="checkbox" value="SC" id="SC">
	  					<label class="form-check-label ZoneStateLabel" for="v">South Carolina</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone2" type="checkbox" value="VA" id="VA">
	  					<label class="form-check-label ZoneStateLabel" for="VA">Virginia</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 2 --->

				<!--- ZONE 3 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone3">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone3">ZONE 3</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone3" type="checkbox" value="AL" id="AL">
	  					<label class="form-check-label ZoneStateLabel" for="AL">Alabama</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone3" type="checkbox" value="GA" id="GA">
	  					<label class="form-check-label ZoneStateLabel" for="GA">Georgia</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone3" type="checkbox" value="TN" id="TN">
	  					<label class="form-check-label ZoneStateLabel" for="TN">Tennessee</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone3" type="checkbox" value="FL" id="FL">
	  					<label class="form-check-label ZoneStateLabel" for="FL">Florida</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone3" type="checkbox" value="MS" id="MS">
	  					<label class="form-check-label ZoneStateLabel" for="MS">Mississippi</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 3 --->

				<!--- ZONE 4 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone4">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone4">ZONE 4</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone4" type="checkbox" value="IN" id="IN">
	  					<label class="form-check-label ZoneStateLabel" for="IN">Indiana</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone4" type="checkbox" value="MI" id="MI">
	  					<label class="form-check-label ZoneStateLabel" for="MI">Michigan</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone4" type="checkbox" value="KY" id="KY">
	  					<label class="form-check-label ZoneStateLabel" for="KY">Kentucky</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone4" type="checkbox" value="OH" id="OH">
	  					<label class="form-check-label ZoneStateLabel" for="OH">Ohio</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 4 --->

				<!--- ZONE 5 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone5">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone5">ZONE 5</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone5" type="checkbox" value="IA" id="IA">
	  					<label class="form-check-label ZoneStateLabel" for="IA">Iowa</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone5" type="checkbox" value="MT" id="MT">
	  					<label class="form-check-label ZoneStateLabel" for="MT">Montana</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone5" type="checkbox" value="SD" id="SD">
	  					<label class="form-check-label ZoneStateLabel" for="SD">South Dakota</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone5" type="checkbox" value="MN" id="MN">
	  					<label class="form-check-label ZoneStateLabel" for="MN">Minnesota</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone5" type="checkbox" value="ND" id="ND">
	  					<label class="form-check-label ZoneStateLabel" for="ND">North Dakota</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone5" type="checkbox" value="WI" id="WI">
	  					<label class="form-check-label ZoneStateLabel" for="WI">Wisconsin</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 5 --->

				<!--- ZONE 6 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone6">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone6">ZONE 6</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone6" type="checkbox" value="IL" id="IL">
	  					<label class="form-check-label ZoneStateLabel" for="IL">Illinois</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone6" type="checkbox" value="KS" id="KS">
	  					<label class="form-check-label ZoneStateLabel" for="KS">Kansas</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone6" type="checkbox" value="MO" id="MO">
	  					<label class="form-check-label ZoneStateLabel" for="MO">Missouri</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone6" type="checkbox" value="NE" id="NE">
	  					<label class="form-check-label ZoneStateLabel" for="NE">Nebraska</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 6 --->

				<!--- ZONE 7 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone7">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone7">ZONE 7</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone7" type="checkbox" value="AR" id="AR">
	  					<label class="form-check-label ZoneStateLabel" for="AR">Arkansas</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone7" type="checkbox" value="OK" id="OK">
	  					<label class="form-check-label ZoneStateLabel" for="OK">Oklahoma</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone7" type="checkbox" value="LA" id="LA">
	  					<label class="form-check-label ZoneStateLabel" for="LA">Louisiana</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone7" type="checkbox" value="TX" id="TX">
	  					<label class="form-check-label ZoneStateLabel" for="TX">Texas</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 7 --->

				<!--- ZONE 8 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone8">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone8">ZONE 8</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="AZ" id="AZ">
	  					<label class="form-check-label ZoneStateLabel" for="AZ">Arizona</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="ID" id="ID">
	  					<label class="form-check-label ZoneStateLabel" for="ID">Idaho</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="NM" id="NM">
	  					<label class="form-check-label ZoneStateLabel" for="NM">New Mexico</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="WY" id="WY">
	  					<label class="form-check-label ZoneStateLabel" for="WY">Wyoming</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="CO" id="CO">
	  					<label class="form-check-label ZoneStateLabel" for="CO">Colorado</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="NV" id="NV">
	  					<label class="form-check-label ZoneStateLabel" for="NV">Nevada</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone8" type="checkbox" value="UT" id="UT">
	  					<label class="form-check-label ZoneStateLabel" for="UT">Utah</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 8 --->

				<!--- ZONE 9 --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zone9">
	  					<label class="form-check-label ZoneHeadingLabel" for="zone9">ZONE 9</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone9" type="checkbox" value="CA" id="CA">
	  					<label class="form-check-label ZoneStateLabel" for="CA">California</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone9" type="checkbox" value="WA" id="WA">
	  					<label class="form-check-label ZoneStateLabel" for="WA">Washington</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone9" type="checkbox" value="OR" id="OR">
	  					<label class="form-check-label ZoneStateLabel" for="OR">Oregon</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zone9" type="checkbox" value="AK" id="AK">
	  					<label class="form-check-label ZoneStateLabel" for="AK">Alaska</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE 7 --->
			</div>
			<div class="col-xs-12 col-lg-6">
				<h2 class="col-xs-12 col-lg-12 blueBg">CANADA & MEXICO</h2>
				<!--- ZONE E --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zoneE">
	  					<label class="form-check-label ZoneHeadingLabel" for="zoneE">ZONE E</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneE" type="checkbox" value="NB" id="NB">
	  					<label class="form-check-label ZoneStateLabel" for="NB">New Brunswick</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneE" type="checkbox" value="NS" id="NS">
	  					<label class="form-check-label ZoneStateLabel" for="NS">Nova Scotia</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneE" type="checkbox" value="NF" id="NF">
	  					<label class="form-check-label ZoneStateLabel" for="NF">New Foundland</label>
					</div>
					<div class="form-check col-xs-6 col-lg-4 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneE" type="checkbox" value="PE" id="PE">
	  					<label class="form-check-label ZoneStateLabel" for="PE">Prince Edward Island</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE E --->

				<!--- ZONE C --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zoneC">
	  					<label class="form-check-label ZoneHeadingLabel" for="zoneC">ZONE C</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneC" type="checkbox" value="ON" id="ON">
	  					<label class="form-check-label ZoneStateLabel" for="ON">Ontario</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneC" type="checkbox" value="QC" id="QC">
	  					<label class="form-check-label ZoneStateLabel" for="QC">Quebec</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE C --->

				<!--- ZONE W --->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zoneW">
	  					<label class="form-check-label ZoneHeadingLabel" for="zoneW">ZONE W</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneW" type="checkbox" value="AB" id="AB">
	  					<label class="form-check-label ZoneStateLabel" for="AB">Alberta</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneW" type="checkbox" value="MB" id="MB">
	  					<label class="form-check-label ZoneStateLabel" for="MB">Manitoba</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneW" type="checkbox" value="BC" id="BC">
	  					<label class="form-check-label ZoneStateLabel" for="BC">British Columbia</label>
					</div>
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneW" type="checkbox" value="SK" id="SK">
	  					<label class="form-check-label ZoneStateLabel" for="SK">Saskatchewan</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE W --->

				<!--- ZONE M--->
				<div class="col-xs-12 col-lg-12">
					<div class="form-check brd-btm">
	  					<input class="form-check-input ZoneHeadingChk" type="checkbox" value="" id="zoneM">
	  					<label class="form-check-label ZoneHeadingLabel" for="zoneM">ZONE M</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<div class="col-xs-2 col-lg-1"></div>
				<div class="col-xs-10 col-lg-11 pl-0 pr-0">
					<div class="form-check col-xs-6 col-lg-3 pl-0 pr-0">
	  					<input name="lanestates" class="form-check-input ZoneStateChk zoneM" type="checkbox" value="MX" id="MX">
	  					<label class="form-check-label ZoneStateLabel" for="MX">Mexico</label>
					</div>
				</div>
				<div class="clearfix"></div>
				<!--- ZONE M --->
				<div class="col-xs-12 col-lg-12 text-center mt-10">
					<cfif isDefined("PrevEvent")>
						<input type="hidden" name="PrevEvent" value="#PrevEvent#">
						<input class="bttn" id="previous-btn" type="submit" name="back" value="PREVIOUS">
					</cfif>
					<label class="stepLabel">STEP #currentStep# OF #TotalStep#</label>
					<cfif isDefined("NextEvent")>
						<input class="bttn" id="next-btn" type="submit" name="submit" value="NEXT">
					</cfif>
				</div>
			</div>
		</div>
	</form>
</cfoutput>