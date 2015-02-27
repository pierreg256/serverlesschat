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
@end
