var parse_app_id = "h2Qs52HrpnNxULdQlMmms75NHVJnQGjymqRLtekF";
var parse_javascript_key = "4rjAqwq7eJZGeoGUiXhqLF5YV1nxktxKbh2G5Hso"

var twilio_accountsid_LIVE = "AC7161535d65fa40e1f8aac6fb0d348fcf";
var twilio_authtoken_LIVE = "17578222e09ba53a92cad40f3160ae61";

var client = require('twilio')('AC7161535d65fa40e1f8aac6fb0d348fcf', '17578222e09ba53a92cad40f3160ae61');

// Include Cloud Code module dependencies
var express = require('express'),
    twilio = require('twilio');
 
var app = express();
app.use(express.urlencoded());
app.post('/hello', function(request, response) {
   
  var body = request.body.Body;
  var objectId = body.substring(0,10);
  var message = body.substring(11,body.length);
  
  var query = new Parse.Query("TextID");
  query.equalTo("objectId",objectId);
  query.first({
     success: function (textID) {
        console.log(textID);
        client.sendSms({
          to:textID.get("phone"), 
          from: '+13104214060', 
          body: message
        }, function(err, responseData) { 
          if (err) {
            console.log(err);
            response.error(err);
          } else { 
            console.log(responseData);
            response.success(responseData);
          }
        }); 
     },
     error: function (httpResponse) {
        console.error(httpResponse.message);
        response.error(httpResponse.message);
     }
  })
});
 
// Start the Express app
app.listen();
/*
Parse.Cloud.define("sendReply", function(request, response) {
  var message = request.params.message;
  var objectId = message.substring(0,10);
  client.sendSms({
          to:'+13105005316', 
          from: '+16144678573', 
          body: 'hi'
        }, function(err, responseData) { 
          if (err) {
            console.log(err);
            response.error(err);
          } else { 
            console.log(responseData);
            response.success(responseData);
          }
        }); 
  var query = new Parse.Query("TextID");
  query.equalTo("objectId",objectId);
  query.first({
     success: function (textID) {
        console.log(textID);
        client.sendSms({
          to:textID.phone, 
          from: '+16144678573', 
          body: 'hi'
        }, function(err, responseData) { 
          if (err) {
            console.log(err);
            response.error(err);
          } else { 
            console.log(responseData);
            response.success(responseData);
          }
        }); 
     },
     error: function (httpResponse) {
        console.error(httpResponse.message);
        response.error(httpResponse.message);
     }
  })
});
*/
