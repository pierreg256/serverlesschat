console.log('Loading event');
var aws = require('aws-sdk');
var s3 = new aws.S3({apiVersion: '2006-03-01'});
var sns = new aws.SNS({region:'eu-west-1'});
var ddb = new aws.DynamoDB({region:'eu-west-1'});
var regex = /^eu-west-1:([0-9a-z\-]+)\/outbox\/([0-9A-Z\-]+)\.json$/;
var events = require('events');


var isSentMessage = function(record) {
  var key          = decodeURIComponent(record.s3.object.key),
      createObject = (record.eventName == "ObjectCreated:Put");

  return ((key.match(regex)) && createObject);
}

var getMessage = function(record, callBack) {
  var bucket   = record.s3.bucket.name,
      key      = decodeURIComponent(record.s3.object.key),
      getParms = {Bucket: bucket, Key: key};

  s3.getObject(getParms, function(getObjectErr, getObjectData){
    if (getObjectErr) {
      console.log('S3: error getting object ' + key + ' from bucket ' + bucket);
      callBack(getObjectErr);
    } else {
      callBack(null, JSON.parse(getObjectData.Body));
    }
  });
};

var copyMessage = function(oldKey, newKey, callBack) {
  var s3parm = {
    Bucket: 'serverlesschat',
    CopySource: 'serverlesschat/'+oldKey,
    Key:newKey,
    StorageClass:'REDUCED_REDUNDANCY'
  };
  s3.copyObject(s3parm, function(copyErr){
    if (copyErr) {
      console.log('S3: error copying object from '+s3parm.CopySource+' to '+s3parm.Key+' in bucket '+s3parm.Bucket);
      callBack(copyErr);
    } else {
      callBack();
    }
  })
}

var deleteMessage = function(key, callBack) {
  var s3parm = {
    Bucket: 'serverlsesschat',
    Key: key
  };
  s3.deleteObject(s3parm, function(deleteErr){
    if (deleteErr){
      console.log('S3: error deleting file ' + s3parm.Key + ' from bucket '+s3parm.Bucket);
      callBack(deleteErr);
    } else {
      callback();
    }
  });
}

var getUserProfile = function(localID, callBack) {
  var ddbParms = {
    TableName: "serverless_id_mappings",
    Key: {
      idProviderID : {
        S: localID
      }
    }
  };

  ddb.getItem(ddbParms, function(ddbErr, ddbData){
    if (ddbErr) {
      console.log('DDB: error getting object idProviderID=' + localID + ' from table ' + ddbParms.TableName);
      callBack(ddbErr);
    } else {
      callBack(null, ddbData.Item);
    }
  });
};

var sendNotif = function(localID, callBack) {
  var ddbParms = {
    TableName: "serverless_device_mappings",
    Key: {
      localID : {
        S: localID
      }
    }
  };

  ddb.getItem(ddbParms, function(ddbErr, ddbData){
    if (ddbErr) {
      console.log('DDB: error getting SNS arn for ' + localID + ' from table ' + ddbParms.TableName);
      callBack(ddbErr);
    } else {
      var endpointArn = ddbData.Item.endpointArn.S;
      var snsMsg = {
        "aps":{
          "alert":"You have new messages...",
          "category":"MESSAGE_CATEGORY",
          "badge":1,
          "sound":"default",
          "content-available":1
        }
      }
      var snsEnvelope = {
        "APNS_SANDBOX":JSON.stringify(snsMsg)
      }
      var snsParms = {
        Message: JSON.stringify(snsEnvelope),
        TargetArn: endpointArn,
        MessageStructure: "json"
      }
      sns.publish(snsParms, function(snsErr, snsData){
        if (snsErr) {
          console.log('SNS: error sending message ' + snsParms);
          callBack(snsErr);
        } else {
          callBack(null);
        }
      });
    }
  });
}

exports.handler = function(event, context) {
  //console.log('Received event:');
  //console.log(JSON.stringify(event, null, '  '));

  var errors = [];
  var recipients = 0;
  var messages = event.Records.length,
      emitter  = new events.EventEmitter;

  emitter.on('error', function(errorObj){
    errors.push(errorObj);
    messages--;
    if (messages<=0){
      context.done(errors, 'Function ended, but with some errors');
    }
  });

  emitter.on('success', function(){
    messages--;
    if (messages<=0){
      context.done(null, '');
    }
  });

  // Do the thing for each and every record
  event.Records.forEach(function(record){
    if (!isSentMessage(record)) {
      console.log("Warning: Not a sent message, skipping...");
      emitter.emit('success');
    } else {
      console.log("Info: fetching message "+record.s3.object.key);
      getMessage(record, function(getError, message){
        if (getError) {
          console.log('Error: failed to fetch message'+record.s3.object.key);
          emitter.emit('error', getError);
        } else {
          //console.log(message);
          recipients = message.to.length;
          message.to.forEach(function(rcptTo){
            console.log('Info: + gathering recipient profile for '+rcptTo);
            getUserProfile(rcptTo, function(userError, profile){
              if (userError) {
                console.log('Error: + failed to fetch recipient profile '+rcptTo);
                emitter.emit('error', userError);
              } else {
                var newKey = profile.localID.S+'/inbox/'+message.id+'.json';

                console.log('Info: + + copying message to '+newKey);
                copyMessage(record.s3.object.key, newKey, function(copyErr){
                  if (copyErr) {
                    console.log('Error: + + failed to copy.');
                    emitter.emit('error', copyErr);
                  } else {
                    recipients--;
                    // send SNS notification
                    console.log('Info: + + sending SNS notif to : '+profile.localID.S);
                    sendNotif(profile.localID.S, function(snsErr){
                      if (snsErr)
                        console.log(snsErr);
                      console.log('Info: + + remaining recipients: '+recipients);
                      if (recipients<=0) {
                        emitter.emit('success');
                      }
                    })
                  }
                });
              }
            });
          });
        }
      }); // End get Message
    }
  }); // End for each record
};

