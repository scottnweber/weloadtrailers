<cfinvoke component="#variables.objloadGateway#" method="getSystemSetupOptions" returnvariable="request.qGetSystemSetupOptions" />
<cfoutput>
    <cfparam name="variables.ID" default="">
    <cfparam name="variables.Name" default="">
    <cfparam name="variables.Description" default="">
    <cfparam name="variables.Active" default="1">
    <cfparam name="variables.CreateDocFrom" default="2">
    <cfparam name="variables.DocEditorInformation" default="">
    <cfparam name="variables.UploadFileName" default="">
    <cfparam name="variables.ZohoTemplateID" default="">
    <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
        <cfinvoke component="#variables.objCarrierGateway#" method="getOnboardingDoc" ID="#url.ID#" returnvariable="qDoc" />
        <cfif qDoc.recordcount>
            <cfset variables.ID = qDoc.ID>
            <cfset variables.Name = qDoc.Name>
            <cfset variables.Description = qDoc.Description>
            <cfset variables.Active = qDoc.Active>
            <cfset variables.CreateDocFrom = qDoc.CreateDocFrom>
            <cfset variables.DocEditorInformation = qDoc.DocEditorInformation>
            <cfset variables.UploadFileName = qDoc.UploadFileName>
            <cfset variables.ZohoTemplateID = qDoc.ZohoTemplateID>
        </cfif>
    </cfif>
    <script language="javascript" type="text/javascript" src="../webroot/javascripts/plugins/ckeditor/ckeditor.js?ver=4.16.0"></script>
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

        
        .white-mid div.form-con input.small_chk{
            width: 14px;
            border: 0px solid ##b3b3b3;
            padding: 0px 0px 0 0px;
            margin: 0 0 2px 0;
            font-size: 11px;
            margin-right: 8px !important;
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
        ##cke_1_bottom {
            display: none;
        }
        
        ##cke_1_contents{
            height: 275px !important;
        }
        .upload-area{
            height: 150px;
            width: 98%;
            border: 1px solid;
            text-align: center;
            
        }

        .upload-area:hover{
            cursor: pointer;
        }

        .upload-area h1{
            color: ##c3c3c3;
            line-height: 25px;
            margin-top: 30px;
        }
        .uploaded-area{
            height: 150px;
            width: 98%;
            border: 1px solid;
            text-align: center;
        }
        ##file{
            display: none;
        }

        .overlay{
            position: fixed;
            width: 100%;
            height: 100%;
            top: 0;
            background-color: ##000;
            opacity: 0.5;
            z-index: 1;
            display: none;
            left: 0;
        }
        ##loader{
            position: fixed;
            top:40%;
            left:40%;
            z-index: 999;
            display: none;
        }
        ##loadingmsg{
            font-weight: bold;
            text-align: center;
            margin-top: 1px;
            background-color: ##fff;
        }
        ##spanUploadFileName{
            margin-left: 5px;
        }
        .msg-area-success{
            border: 1px solid ##a4da46;
            padding: 5px 15px;
            font-weight: normal;
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##b9e4b9;
            font-weight: bold;
            font-style: italic;
        }
        .msg-area-error{
            border: 1px solid ##da4646;
            padding: 5px 15px;
            font-weight: normal;
            width: 82%;
            float: left;
            margin-top: 5px;
            margin-bottom:  5px;
            background-color: ##e4b9c6;
            font-weight: bold;
            font-style: italic;
        }
    </style>
    <script>
        $(document).ready(function(){
            <cfif structKeyExists(session, "OnboardingDocSaveMessage") AND structKeyExists(session.OnboardingDocSaveMessage,"editTemplate")>
                openTemplatePopup();
            </cfif>
            var configNew = {};
            configNew.extraPlugins = 'justify,uicolor,colorbutton,colordialog,font';
            configNew.toolbarGroups  = [
                { name: 'basicstyles', groups: ['basicstyles']},
                { name: 'paragraph', groups: ['align'] },
                
            ];
            configNew.removeButtons = 'Strike,Subscript,Superscript,JustifyBlock';
            configNew.contentsCss = 'p {margin:0};';
            CKEDITOR.replace('DocEditorInformation', configNew);

            $("html").on("dragover", function(e) {
                e.preventDefault();
                e.stopPropagation();
                $(".uplH1").text("Drag here");
            });

            $("html").on("drop", function(e) { e.preventDefault(); e.stopPropagation(); });

            $('.upload-area').on('dragenter', function (e) {
                e.stopPropagation();
                e.preventDefault();
                $(".uplH1").text("Drop");
            });

            $('.upload-area').on('dragover', function (e) {
                e.stopPropagation();
                e.preventDefault();
                $(".uplH1").text("Drop");
            });

            $('.upload-area').on('drop', function (e) {
                e.stopPropagation();
                e.preventDefault();
                $(".uplH1").text("Upload");
                var file = e.originalEvent.dataTransfer.files;
                var fd = new FormData();
                fd.append('file', file[0]);
                uploadData(fd);
            });

            $(".upload-area").click(function(){
                $("##file").click();
            });

            $("##file").change(function(){
                var fd = new FormData();
                var files = $('##file')[0].files[0];
                fd.append('file',files);
                uploadData(fd);
            });
        })

        function uploadData(formdata){
            $.ajax({
                url: 'ajax.cfm?event=ajxUploadCarrierDoc&#session.URLToken#',
                type: 'post',
                data: formdata,
                contentType: false,
                processData: false,
                dataType: 'json',
                beforeSend: function() {
                   $(".overlay").show();
                   $("##loader").show();
                },
                success: function(response){
                    if(response.success==0){
                        $("##loader").hide();
                        $(".overlay").hide();
                        alert(response.message)
                    }
                    else{
                        $('##uploadFileName').val(response.fileName);
                        if(!$.trim($('##Name').val()).length){
                            $('##Name').val(response.fileName.replace(".pdf", ""));
                        }
                        if(!$.trim($('##Description').val()).length){
                            $('##Description').val(response.fileName.replace(".pdf", ""));
                        }
                        $('##DocForm').submit();
                    }
                    $(".uplH1").html("DRAG AND DROP FILE HERE<br>OR CLICK TO BROWSE");
                }
            });
        }

        function validateDoc(){
            var CreateDocFrom = $('input[name="CreateDocFrom"]:checked').val();
            if($.trim($('##Name').val().length)==0){
                alert('Please enter Name.');
                $('##Name').focus();
                return false;
            }
            else if($.trim($('##Description').val().length)==0){
                alert('Please enter Description.');
                $('##Description').focus();
                return false;
            }
            else if(CreateDocFrom==1 && !validateDocEditor()){
                return false;
            }
            else if(CreateDocFrom==2 && $.trim($('##uploadFileName').val().length)==0){
                alert('Please upload file.')
                return false;
            }
            else{
                return true;
            }
            return false;
        }

        function validateDocEditor(){
            var arrTagVariables = ['{DOT}', '{MC##}', '{NAME}', '{ADDRESS1}', '{ADDRESS2}', '{CITY}', '{STATE}', '{ZIP}', '{COUNTRY}', '{PHONE}', '{MOBILE}', '{EMAIL}', '{CONTACT NAME}'];
            var editorText = CKEDITOR.instances["DocEditorInformation"].getData()
            var arrMissingTags = [];

            for(i=0;i<arrTagVariables.length;i++){
                if(editorText.indexOf(arrTagVariables[i])==-1){
                    arrMissingTags.push(arrTagVariables[i]);
                }
            }
            if(arrMissingTags.length){
                alert('Missing tag variables:\n'+arrMissingTags);
                return false;
            }
            else{
                return true;
            }
        }

        function docOption(id){
            $('##div_DocEditorInformation').hide();
            $('##div_uploadcontainer').hide();
            $('##div_'+id).show();
        }

        function openTemplatePopup(){
            var h = screen.height;
            var w = screen.width;
            <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
                var url ='index.cfm?event=editTemplate&ID=#url.ID#&#session.URLToken#';
                newwindow=window.open(url,'name','height='+h +',width='+w);
                if (window.focus) {newwindow.focus()}
            </cfif>
        }
    </script>


    <div class="clear"></div>
    <cfif structKeyExists(session, "OnboardingDocSaveMessage")>
        <div id="message" class="msg-area-#session.OnboardingDocSaveMessage.res#">#session.OnboardingDocSaveMessage.msg#</div>
        <cfset structDelete(session, "OnboardingDocSaveMessage")>
        <div class="clear"></div>
    </cfif>
    <cfinclude template="OnboardingDocTab.cfm">
    <div class="white-con-area" style="height: 36px;background-color: ##82bbef;width:852px;text-align: center;">
        <h2 style="color:white;font-weight:bold;">Onboarding Docs</h2>
    </div>
    <div class="clear"></div>
    <h1 style="display: inline-block;"><cfif structKeyExists(url, "ID") AND len(trim(url.ID))>Edit<cfelse>Add</cfif> Onboarding Doc</h1>
    <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
        <div class="delbutton" style="padding: 12px 175px 0px 0;">
            <a href="index.cfm?event=DeleteOnBoardingDoc&ID=#url.id#&UploadFileName=#encodeForURL(variables.UploadFileName)#&ZohoTemplateID=#variables.ZohoTemplateID#&#session.URLToken#" onclick="return confirm('Are you sure you want to delete this doc?');">  Delete</a>
        </div>
    </cfif>
    <div class="clear"></div>
    <cfform id="DocForm" name="DocForm" action="index.cfm?event=AddOnboardingDoc:Process&#session.URLToken#" method="post" preserveData="yes" onsubmit="return validateDoc();">
        <input type="hidden" name="ID" value="#variables.ID#">
        <input type="hidden" name="ZohoTemplateID" value="#variables.ZohoTemplateID#">
        <div class="clear"></div>
        <div class="white-con-area">
            <div class="white-mid" style="padding-bottom: 25px;">
                <div class="form-con">
                    <fieldset>
                        <label>Name*</label>
                        <input name="Name" id="Name" type="text" value="#variables.Name#" maxlength="250">
                        <div class="clear"></div>
                        <label>Description*</label>
                        <textarea name="Description" id="Description" maxlength="250">#variables.Description#</textarea>
                        <div class="clear"></div>
                        <label>Active:</label>
                        <input name="Active" id="Active" type="checkbox" value="1" class="small_chk" style="float: left;" <cfif variables.Active> checked </cfif>>
                        <div class="clear"></div>
                        <input id="saveLoad" name="save" type="submit" class="green-btn" value="Save" style="margin-left: 110px;">
                        <input type="button" onclick="document.location.href='index.cfm?event=OnboardCarrierDocs&#session.URLToken#'" name="cancel" class="bttn" value="Cancel" style="width: 125px !important;">
                    </fieldset>
                </div>
                <div class="form-con">
                    <fieldset>
                        <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
                            <div>
                                <h1 style="padding: 0px 0px 10px 65px;font-style:italic;">Click document below to EDIT</h1>
                            </div>
                            <input type="radio" name="CreateDocFrom" value="1" hidden style="width:12px;" <cfif variables.CreateDocFrom EQ 1> checked </cfif> onclick="docOption('DocEditorInformation')">
                            <input type="radio" name="CreateDocFrom" value="2" hidden style="width:12px;margin-left: 25px;" <cfif variables.CreateDocFrom EQ 2> checked </cfif> onclick="docOption('uploadcontainer')">
                        <cfelse>
                            <label>Create Doc From:</label>
                            <input type="radio" name="CreateDocFrom" value="1" style="width:12px;" <cfif variables.CreateDocFrom EQ 1> checked </cfif> onclick="docOption('DocEditorInformation')"><span style="float:left;">Doc Editor</span>
                            <input type="radio" name="CreateDocFrom" value="2" style="width:12px;margin-left: 25px;" <cfif variables.CreateDocFrom EQ 2> checked </cfif> onclick="docOption('uploadcontainer')"><span style="float:left;">Upload File</span>
                        </cfif>
                        <div class="clear"></div>
                        <div id="div_DocEditorInformation" <cfif variables.CreateDocFrom EQ 2>style="display:none;"</cfif>>
                            <textarea id="DocEditorInformation" name="DocEditorInformation" style="height: 300px;width: 98%;">#variables.DocEditorInformation#</textarea>
                        </div>
                        <input type="file" name="file" id="file">
                        <input type="hidden" name="uploadFileName" id="uploadFileName" value="#variables.uploadFileName#">
                        <cfif structKeyExists(url, "ID") AND len(trim(url.ID))>
                            <div id="" <cfif variables.CreateDocFrom EQ 1>style="display:none;"</cfif>>
                                <div class="uploaded-area" id="">
                                    <div style="margin-top:10%;">
                                        <img style="cursor: pointer;" src="images/pdf-icon-64.png" onclick="openTemplatePopup();">
                                        <a <cfif not len(trim(variables.uploadFileName))>style="display: none;"</cfif> id="uploadPreviewLink"  href="##" onclick="openTemplatePopup();" title="Click here to view the file.">
                                            <span id="spanUploadFileName">#variables.uploadFileName#</span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        <cfelse>
                            <div id="div_uploadcontainer" <cfif variables.CreateDocFrom EQ 1>style="display:none;"</cfif>>
                                <div class="upload-area" id="div_DocUpload">
                                    <h1 class="uplH1">DRAG AND DROP FILE HERE<br>OR CLICK TO BROWSE</h1>
                                </div>
                                <div class="clear" style="margin-top: 10px;"></div>
                                <a <cfif not len(trim(variables.uploadFileName))>style="display: none;"</cfif> id="uploadPreviewLink"  href="##" onclick="openTemplatePopup();" title="Click here to view the file.">
                                    <img src="images/pdf-icon-64.png"><br><span id="spanUploadFileName">#variables.uploadFileName#</span>
                                </a>
                            </div>
                        </cfif>
                    </fieldset>
                </div>
                <div class="clear"></div>
            </div>
            <div class="white-bot"></div>
        </div>
    </cfform>  
    <div class="overlay"></div>
    <div id="loader">
        <img src="images/loadDelLoader.gif">
        <p id="loadingmsg">Please wait.</p>
    </div>
</cfoutput>

    