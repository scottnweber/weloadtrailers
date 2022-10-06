<cfoutput>
<!---Init the default value------->	  
<cfsilent>
	<cfset requireValidMCNumber = request.qGetSystemSetupOptions.requireValidMCNumber>
						
	<cfparam name="MCNumber" default=""> 
	<cfparam name="customerid" default="">  
</cfsilent>

<cfset session.checkUnload ='add'>
<h1>Enter New Customer</h1>

<cfif isDefined("SaveContinue")>
 	<cfset messageHead='Please enter either MC## or DOT## to add new Customer. If you dont have that use their phone## instead.'>
	<cfif isDefined("MCNumber") and len(trim(MCNumber)) gt 0>
        <cfinvoke component="#request.cfcpath#.loadgateway" method="checkcustomerMCNumber" returnvariable="request.qcustomer"> 
         	<cfinvokeargument name="McNumber" value="#McNumber#">
         	<cfinvokeargument name="dsn" value="#application.dsn#">
        </cfinvoke>
        <cfif  request.qcustomer.recordcount gte 1>
            <cfset customerid=request.qcustomer.customerid>
            <cfset message='<a href="index.cfm?event=addcustomer&customerid=#request.qcustomer.customerid#&#session.URLToken#" style="text-decoration:font:bold;padding-left:96px;"> MC##  #McNumber# </a>'  &"already existed">
        <cfelse>
	        <cflocation url="index.cfm?event=addcustomer&mcno=#trim(McNumber)#" AddToken="Yes">         
        </cfif>  
	<cfelseif structKeyExists(form, "DOTNumber") and len(trim(DOTNumber)) gt 0>
        <cfinvoke component="#request.cfcpath#.loadgateway" method="checkcustomerMCNumber" returnvariable="request.qcustomer"> 
        	<cfinvokeargument name="DOTNumber" value="#form.DOTNumber#">
        	<cfinvokeargument name="dsn" value="#application.dsn#">
        </cfinvoke>

		<cfif  request.qcustomer.recordcount gte 1>
            <cfset customerid=request.qcustomer.customerid>
            <cfset message='<a href="index.cfm?event=addcustomer&customerid=#request.qcustomer.customerid#&#session.URLToken#" style="text-decoration:font:bold;padding-left:96px;"> DotNumber##  #form.DOTNumber# </a>'  &"already existed">
        <cfelse>
	        <cflocation url="index.cfm?event=addcustomer&DOTNumber=#trim(DOTNumber)#" AddToken="Yes">         
         </cfif> 
    <cfelseif not structKeyExists(form, "DOTNumber") and not len(trim(DOTNumber)) gt 0> 
     	<cflocation url="index.cfm?event=addcustomer&DOTNumber=" AddToken="Yes">  
    <cfelseif not structKeyExists(form, "MCNumber") and not len(trim(MCNumber)) gt 0>      
		<cflocation url="index.cfm?event=addcustomer&mcno=" AddToken="Yes">              
    </cfif> 
</cfif>
<cfif not (isdefined("message") and len(message))>
	<cfif isdefined("messageHead") and len(messageHead)>
	<div class="msg-area" style="margin-left: 13px;">#messageHead#</div>
	</cfif>
</cfif>

<div class="white-con-area">
		<div class="white-top"></div>
		<div class="white-mid-carrier">
		 <cfform name="frmNewCarrier" action="index.cfm?event=addnewcustomer:process&#session.urltoken#" method="post">
				<div class="form-con">
				 <fieldset>
				   <cfinput type="hidden" name="customerid" id="customerid" value="#customerid#">
			       <cfif isdefined("message") and len(message)>
			         <div class="msg-carr">
			           
			           <div class="form-con">  
				           <ul class="load-link">                                                           
				       			<li><font size="3">#message#</font></li>
	                       </ul> 
                       </div>                        
			         </div>
			       </cfif>
					    <div class="clear"></div>
					   <label class="DOTNumber" style="padding-left: 39px;"><span style="color:##448bc8;"><i>Please enter...</i></span>DOT ##</label>
                      	<cfinput name="DOTNumber" id="DOTNumber" type="text" value="" maxlength="50"/>
                      		
				        <label><span style="color:##448bc8;"><i>...OR...</i></span><span style="margin-left: 34px;"> MC ##</span></label>
						<cfif requireValidMCNumber EQ True>
                    	  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1" maxlength="50" value="#MCNumber#"  /> 				
                    	<cfelse>
						  <cfinput name="MCNumber" id="MCNumber" type="text" tabindex="1" maxlength="50" value="#MCNumber#"  />
						</cfif>
						
						<div class="clear"></div>
                        <cfinput name="SaveContinue" id="continue-btn" type="submit" class="normal-bttn" value="Continue>>"  onfocus="checkUnload();" style="margin-left: 533px; margin-top: -29px;"/>                    		 
                  </fieldset>
				  </div>						
			<div class="clear"></div>					
		</cfform>
		<div class="clear"></div>
		</div>					
		<div class="white-bot"></div>
</div>
<script type="text/javascript">
	$(document).ready(function(){
		$('##continue-btn').click(function(){
			var MCnum = $('##MCNumber').val();
			var DOTnum = $('##DOTNumber').val();
		});
	});
</script>
</cfoutput>	
