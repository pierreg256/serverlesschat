var lambda = require('./function');
var context = {};

context.done = function(err, message) {
    if (err)
        console.log(message);
    else
        console.log('finished')
}

var event = {
    "Records": [
        {
            "eventVersion": "2.0",
            "eventSource": "aws:s3",
            "awsRegion": "eu-west-1",
            "eventTime": "2015-03-04T15:41:10.470Z",
            "eventName": "ObjectCreated:Put",
            "userIdentity": {
                "principalId": "AWS:AROAJ4EFUGXP6QOV6XF74:CognitoIdentityCredentials"
            },
            "requestParameters": {
                "sourceIPAddress": "54.240.197.233"
            },
            "responseElements": {
                "x-amz-request-id": "FE28C90FC3C29D61",
                "x-amz-id-2": "vX+XMTqVZ78YfIY6OFZWOkI5r3bh6X1/uDIY0O3RXYb5hbaq2dPTN3F2rlQYSdJuhWBuzGhIZiA="
            },
            "s3": {
                "s3SchemaVersion": "1.0",
                "configurationId": "quickCreateConfig",
                "bucket": {
                    "name": "serverlesschat",
                    "ownerIdentity": {
                        "principalId": "ASR4ZG1F1B4TV"
                    },
                    "arn": "arn:aws:s3:::serverlesschat"
                },
                "object": {
                    "key": "eu-west-1%3Af256dbe2-2201-4024-b15d-2ab403db78ba/outbox/E445330E-25E9-405D-80B7-861673B80499.json",
                    "size": 184,
                    "eTag": "fe49bb277ec801ddedd8f2b3941e91ba"
                }
            }
        }
    ]
};

lambda.handler(event, context);