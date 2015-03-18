//
//  SLChatHelper.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 26/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "SLChatHelper.h"
#import "PGTContact.h"
#import "DynamoDB.h"
#import "S3.h"
#import "AWSCore.h"
#import "PGTConversation.h"

@implementation SLChatHelper
static AWSDynamoDBObjectMapper *dynamoDBObjectMapper ;

+(void)updateProfile
{
    if (!dynamoDBObjectMapper) {
        dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        dynamoDBObjectMapper.configuration.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdateSkipNullAttributes;
    }
    
    
    [[dynamoDBObjectMapper save:[PGTContact me]] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%s - %@",__PRETTY_FUNCTION__,task.error);
        } else {
            PGTMapping* mapping = [[PGTMapping alloc] init];
            mapping.localID = [PGTContact me].localID;
            mapping.idProvider = [PGTContact me].idProvider;
            mapping.idProviderID = [PGTContact me].idProviderID;
            [[dynamoDBObjectMapper save:mapping] continueWithBlock:^id(BFTask *task) {
                if (task.error) {
                    NSLog(@"%s - %@",__PRETTY_FUNCTION__,task.error);
                } else {
                    NSLog(@"%s - success!",__PRETTY_FUNCTION__);
                }
                return nil;
            }];
        }
        return nil;
        

    }];
    
}

+(void)updateDeviceMapping
{
    PGTDeviceMapping* map = [[PGTDeviceMapping alloc] init];
    map.localID = [PGTContact me].localID;
    map.endpointArn = [[NSUserDefaults standardUserDefaults] objectForKey:@"endpointArn"];
    
    if (!dynamoDBObjectMapper) {
        dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        dynamoDBObjectMapper.configuration.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdateSkipNullAttributes;
    }
    
    NSLog(@"%s - sending the following object: %@", __PRETTY_FUNCTION__,map);
    
    [[dynamoDBObjectMapper save:map] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, task.error);
        }
        return nil;
    }];
}

+(void)sendMessageToDynamo:(PGTMessageOut *)message
{
    if (!dynamoDBObjectMapper) {
        dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        dynamoDBObjectMapper.configuration.saveBehavior = AWSDynamoDBObjectMapperSaveBehaviorUpdateSkipNullAttributes;
    }
    
    NSLog(@"%s - sending the following object: %@", __PRETTY_FUNCTION__,message);

    [[dynamoDBObjectMapper save:message] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, task.error);
        }
        return nil;
    }];
}

+(void)sendMessage:(PGTMessageOut *)message
{
    //[message toNSDictionary];
    NSError* error;
    
    NSDictionary* jsonObject = [message toNSDictionary];
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, jsonObject);
    
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        NSLog(@"%s - valid json object", __PRETTY_FUNCTION__);

        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        
        AWSS3PutObjectRequest *request = [[AWSS3PutObjectRequest alloc] init] ;
        request.key = [NSString stringWithFormat:@"%@/outbox/%@.json", [PGTContact me].localID, message.id];
        request.bucket = @"serverlesschat";
        request.body = jsonData;
        request.contentLength = [NSNumber numberWithUnsignedInt:[jsonData length]];
        request.storageClass = AWSS3StorageClassReducedRedundancy;
        request.contentType = @"application/json";
        
        // Note that request.delegate is not set.
        [[[AWSS3 defaultS3] putObject:request] continueWithBlock:^id(BFTask *task) {
            if (task.error) {
                NSLog(@"%s - %@", __PRETTY_FUNCTION__, task.error);
            } else {
                NSLog(@"%s - stored",__PRETTY_FUNCTION__);
            }
            
            return nil;
        }];

    } else {
        NSLog(@"%s - not valid json object!", __PRETTY_FUNCTION__);
        
    }
}

+(void)fetchMessagesWithCompletionHandler:(void (^)(NSArray* result))completionHandler{
    AWSS3ListObjectsRequest *request = [[AWSS3ListObjectsRequest alloc] init] ;
    request.prefix = [NSString stringWithFormat:@"%@/inbox/", [PGTContact me].localID];
    request.bucket = @"serverlesschat";
    
    [[[AWSS3 defaultS3] listObjects:request] continueWithBlock:^id(BFTask *task) {
        NSMutableArray* res = [[NSMutableArray alloc] init];
        if (task.error) {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, task.error);
        } else {
            NSArray* contents = ((AWSS3ListObjectsOutput*)task.result).contents;
            //NSLog(@"%s - %@",__PRETTY_FUNCTION__,contents);
            [contents enumerateObjectsUsingBlock:^(AWSS3Object* obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"%s - %@", __PRETTY_FUNCTION__, obj.key);
                AWSS3GetObjectRequest* getObjRequest = [[AWSS3GetObjectRequest alloc]init];
                getObjRequest.bucket = @"serverlesschat";
                getObjRequest.key = obj.key;
                [[[AWSS3 defaultS3] getObject:getObjRequest] continueWithBlock:^id(BFTask *task) {
                    if (task.error) {
                        NSLog(@"%s - %@",__PRETTY_FUNCTION__, task.error);
                    } else {
                        NSError* error;
                        NSDictionary* msgDict =  [NSJSONSerialization JSONObjectWithData:((AWSS3GetObjectOutput*)(task.result)).body options:0 error:&error];
                        
                        PGTMessageIn* msg = [[PGTMessageIn alloc] initWithDictionary:msgDict error:&error];
                        msg.read = [NSNumber numberWithBool:NO];
                        // We have a message, let's try and add it to an existing conversation
                        [PGTConversation handleNewMessage:msg];
                        //NSLog(@"%s - %@", __PRETTY_FUNCTION__, msg);
                    }
                    
                    return nil;
                }];
            }];
            completionHandler(contents);
        }
        
        return nil;
    }];
}

@end
