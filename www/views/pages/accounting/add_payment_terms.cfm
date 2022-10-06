<cfoutput>
    <cfif structKeyExists(url, "deleteID")>
        <cfinvoke component="#variables.objLoadGateway#" method="deletePaymentTerm" ID="#url.deleteID#" returnvariable="session.TermMessage"/>
        <cflocation url="index.cfm?event=PaymentTerms&#session.URLToken#">
    </cfif>
    <cfif structKeyExists(form, "submitPaymentTerm")>
        <cfinvoke component="#variables.objLoadGateway#" method="savePaymentTerm" frmstruct="#form#" returnvariable="session.TermMessage"/>
        <cflocation url="index.cfm?event=PaymentTerms&#session.URLToken#">
    </cfif>
    <cfparam name="variables.ID" default="">
    <cfparam name="variables.Description" default="">
    <cfparam name="variables.Type" default="">
    <cfparam name="variables.Discount" default="0">
    <cfparam name="variables.DiscountDays" default="0">
    <cfparam name="variables.NetDays" default="0">
    <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
        <cfinvoke component="#variables.objLoadGateway#" method="getLMAPaymentTermDetail" ID="#url.ID#" returnvariable="qPaymentTerm" />
        <cfif qPaymentTerm.recordcount>
            <cfset variables.ID = qPaymentTerm.ID>
            <cfset variables.Description = qPaymentTerm.Description>
            <cfset variables.Type = qPaymentTerm.Type>
            <cfset variables.Discount = qPaymentTerm.Discount>
            <cfset variables.DiscountDays = qPaymentTerm.DiscountDays>
            <cfset variables.NetDays = qPaymentTerm.NetDays>
        </cfif>
    </cfif>
    <style type="text/css">
        .white-mid div.form-con label {
            float: left;
            text-align: right;
            width: 140px;
            padding: 0 10px 0 0;
            font-size: 11px;
            font-weight: bold;
            color: ##000000;
        }
        .white-mid div.form-con input {
            float: left;
            width: 200px;
            background: ##FFFFFF;
            border: 1px solid ##b3b3b3;
            padding: 2px 2px 0 2px;
            margin: 0 0 8px 0;
            font-size: 11px;
            margin-right: 8px !important;
            height: 18px;
        }
        .btn {
            background: url(../webroot/images/button-bg.gif) left top repeat-x;
            border: 1px solid ##b3b3b3;
            padding: 0 10px;
            height: 20px;
            font-size: 11px;
            font-weight: bold;
            line-height: 20px;
            text-align: center;
            margin: 2px;
            color: ##599700;
            width: 125px !important;
            cursor: pointer;
            margin-left: 150px;
        }
    </style>
    <script>
        $(document).ready(function(){
            $('##Discount').change(function(){
                if(isNaN($('##Discount').val().replace(/[$,]/g, ''))){
                    $('##Discount').val('$0.00');
                }
                var val = $('##Discount').val();
                formatDollarNegative(val, 'Discount');
            })
        })
        function validateTerm(){
            if($.trim($('##Description').val().length)==0){
                alert('Please enter Description.');
                $('##Description').focus();
                return false;
            }
            else if($.trim($('##Type').val().length)==0){
                alert('Please enter Type.');
                $('##Type').focus();
                return false;
            }
            else{
                return true;
            }
            return false;
        }
    </script>
    <h1><cfif structKeyExists(url, "ID") AND len(trim(url.ID))>Edit<cfelse>Add</cfif> Payment Term</h1>
    <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>    
        <div class="delbutton" style="float:left;margin-left: 340px;margin-top: -33px;">
            <a href="index.cfm?event=addLMAPaymentTerms&deleteid=#url.id#&#session.URLToken#" onclick="return confirm('Are you sure you want to delete this term?');">  Delete</a>
        </div>
    </cfif>
    <div class="clear"></div>
    <cfform id="PaymentTermForm" name="PaymentTermForm" action="index.cfm?event=addLMAPaymentTerms&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateTerm();">
        <input type="hidden" name="ID" value="#variables.ID#">
        <div class="clear"></div>
        <div class="white-con-area" style="width:999px">
            <div class="white-mid" style="width:999px">
                <div class="form-con" style="width:400px;padding:0;background-color: ##defaf9 !important;">
                    <div style="height: 36px;background-color: ##82bbef;margin-bottom: 5px;float: right;">
                        <h2 style="color:white;font-weight:bold;padding-top: 10px;width:390px;text-align: center;"><cfif structKeyExists(url, "ID") AND len(trim(url.ID))>#variables.description#<cfelse>Payment Term</cfif></h2>
                    </div>
                    <label>Description:</label>
                    <input name="Description" id="Description" type="text" value="#variables.Description#" maxlength="30" tabindex="1">
                    <div class="clear"></div>
                    <label>Discount Type:</label>
                    <input name="Type" id="Type" type="text" value="#variables.Type#" maxlength="1" tabindex="2" style="width:30px;">
                    <div class="clear"></div>
                    <label>Discount:</label>
                    <input name="Discount" id="Discount" type="text" value="#DollarFormat(variables.Discount)#" maxlength="25" tabindex="3" style="width:50px;">
                    <div class="clear"></div>
                    <label>Discount Days:</label>
                    <input name="DiscountDays" type="text" value="#variables.DiscountDays#" maxlength="10" style="width:50px;" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'0')" >
                    <div class="clear"></div>
                    <label>Net Days:</label>
                    <input name="NetDays" type="text" value="#variables.NetDays#" maxlength="10" tabindex="5" style="width:50px;" onkeyup="if (/\D/g.test(this.value)) this.value = this.value.replace(/\D/g,'0')" >
                    <div class="clear"></div>
                    <button class="btn" name="submitPaymentTerm"><b>Save</b></button>
                    <button class="btn" name="cancel"><b>Cancel</b></button>
                </div>
            </div>
        </div>
    </cfform>  
</cfoutput>

    