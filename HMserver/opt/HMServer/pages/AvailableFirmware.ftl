<!DOCTYPE html>
<html>
  <head>

  </head>
  <body>
   <table id="DeviceListTable" cellpadding="0" cellspacing="0">
    <colgroup>
      <col width="5%">
      <col width="30%">
      <col width="25%">
      <col width="25%">
      <col width="15%">
    </colgroup>
    <thead>
      <tr>
        <th class="DeviceListHead" name="thPic">${"$"}{thPicture}</th>
        <th class="DeviceListHead" name="thName">${"$"}{thName}</th>
        <th class="DeviceListHead" name="thVersion">${"$"}{thVersion}</th>
        <th class="DeviceListHead" name="thMinCCU">${"$"}{thMinCCU}</th>
        <th class="DeviceListHead" name="thAction">${"$"}{thAction}</th>
      </tr>
    </thead>
    <tbody>

      <!-- Creates the table rows with all available firmware versions -->
      ${deviceRow}

    </tbody>
   </table>

   <script type="text/javascript">
   	  var s = "";
   	  s += "<table cellspacing='8'>";
   	  s += "<tr>";
   	  s += "<td align='center' valign='middle'><div class='FooterButton' onclick='WebUI.goBack();'>"+ translateKey('footerBtnPageBack') +"</div></td>";
 			s += "<td align='center' valign='middle'><div class='FooterButton' onclick='addNewFirware();'>"+ translateKey('footerBtnNew') +"</div></td>";
      setFooter(s);

      deleteFirmware = function(fwID, devName) {
        //new YesNoDialog("title - Bestaetigung","body - Wollen Sie die Firmware wirklich vom System entfernen?",function(result) {
        new YesNoDialog(translateKey("delDevFirmwareMsgTitle"),translateKey("delDevFirmwareMsgBody"),function(result) {
          if (result == YesNoDialog.RESULT_YES) {
            var url = '/pages/jpages/system/DeviceFirmware/deleteFirmware?sid=' + SessionId;
            var pb ='{';
            pb += '"firmwareID": ' + '"' + fwID + '",';
            pb += '"deviceName": ' + '"' + devName + '"';
            pb += '}'
            var opt= {
              postBody: pb,
              onComplete: function(t) {
                var response = JSON.parse(t.responseText);
                //jQuery("#content").html(response.content);
                if(!response.isSuccessful)
                {
                  if(response.errorCode == "42")
                  {
                    jQuery("#content").html(translateString(response.content));
                  } else {
                    alert("deleteFirmware: Something very strange happend here :-(");
                  }
                } else {
                    // all right
                    MessageBox.show("Delete firmware", translateString(response.content));
                    WebUI.reload();
                    var ok = homematic("Interface.refreshDeployedDeviceFirmwareList", {"interface": "BidCos-RF"});
                    conInfo("Delete firmware - refreshing device firmware list: " + ok);
                }
              }
            }
            new Ajax.Request(url, opt);
          }
        });
      };

      addNewFirware = function() {
        try {
          var tmp = new FormData();
        } catch(e) {
          addFirmwareOldFashioned(); // IE8 u. IE9
          return;
        }
        var file;
        //var msgContent = "<b>Waehle die gewuenschte Firmware:</b><br/><br/>";
        var msgContent = "<b>"+translateKey("addFirmwareMsgBody")+"</b><br/><br/>";

        msgContent += "<form id='fileupload' name='fileupload' enctype='multipart/form-data' method='post'>"
        msgContent += "  <fieldset>"
        msgContent += "    <input type='file' name='fileselect' id='fileselect'></input>"
        msgContent += "  </fieldset>"
        msgContent += "</form>"

        new YesNoDialog(translateKey("addFirmwareMsgTitle"),msgContent, function(result) {
          if (result == YesNoDialog.RESULT_YES) {

          var formData = new FormData();
          formData.append('file', file);
          var url = '/pages/jpages/system/DeviceFirmware/addFirmware?sid=' + SessionId;

            jQuery.ajax({
              url: url,
              type: "post",
              data: formData,
              processData:false,
              contentType: false,
              success: function(result) {
                MessageBox.show(translateKey("dialogInfo"),translateString(result), null,"320", "80");
                WebUI.reload();
                var ok = homematic("Interface.refreshDeployedDeviceFirmwareList", {"interface": "BidCos-RF"});
                conInfo("Add firmware - refreshing device firmware list: " + ok);
              },
              error: function(error) {
              conInfo(error.statusText);
              }
            });
          }
        }, "html");

        // Set an event listener on the Choose File field.
        jQuery("#fileselect").bind("change", function(e) {
          jQuery(".YesNoDialog_yesButton").show();
          var files = e.target.files || e.dataTransfer.files;
          // Our file var now holds the selected file
          file = files[0];
        });

        jQuery(".YesNoDialog_yesButton").hide().text(translateKey("dialogSettingsCMBtnPerformSoftwareUpdateUpload"));
        jQuery(".YesNoDialog_noButton").text(translateKey("btnCancel"));
      };

      // This is for IE8 and IE9 neccessary
      addFirmwareOldFashioned = function() {

        var msgContent = "<b>"+translateKey("addFirmwareMsgBody")+"</b><br/><br/>";
        msgContent += "<form id='uploadForm' action='/pages/jpages/system/DeviceFirmware/addFirmware?sid="+SessionId+"' method='post' enctype='multipart/form-data'>";
          msgContent += "Firmware: <input type='file' name='file' />";
          msgContent += "<br/><br/><div style='text-align:right;'><input id='btnSubmit' type='submit' value='"+translateKey('dialogSettingsCMBtnPerformSoftwareUpdateUpload')+"' /></div>";
        msgContent += "</form>";

        ynDlg = new YesNoDialog(translateKey("addFirmwareMsgTitle"),msgContent, function(result){

        },"html");

        var options = {
          success: function(response) {
            ynDlg.close();
            MessageBox.show(translateKey("dialogInfo"),translateString(response), null,"320", "80");
            WebUI.reload();
            var ok = homematic("Interface.refreshDeployedDeviceFirmwareList", {"interface": "BidCos-RF"});
            conInfo("Add firmware - refreshing device firmware list: " + ok);
          }
        };

        jQuery('#uploadForm').submit(function() {
          jQuery(this).ajaxSubmit(options);
            return false;
        });

        jQuery('#btnSubmit').live("submit",function(event) {
          event.prefentDefault();
        });

        jQuery(".YesNoDialog_yesButton").hide().text(translateKey("btnUpload"));
        jQuery(".YesNoDialog_noButton").text(translateKey("btnCancel"));

      };

      showChangelog = function(fwID) {
          var url = '/pages/jpages/system/DeviceFirmware/showChangelog?sid=' + SessionId;
          var pb ='{';
          pb += '"firmwareID": ' + '"' + fwID + '"';
          pb += '}'
          var opt= {
            postBody: pb,
            onComplete: function(t) {
              var response = JSON.parse(t.responseText);
              if(!response.isSuccessful)
              {
                if(response.errorCode == "42")
                {
                  jQuery("#content").html(translateString(response.content));
                } else {
                  alert("Show changelog: Something very strange happend here :-(");
                }
              } else {
                  // all right
                  MessageBox.show(translateKey("dialogChangeLogTitle"), translateString(response.content),"", "600", "400");
              }
            }
          }
          new Ajax.Request(url, opt);
      };

      translatePage();

   </script>
  </body>
</html>
