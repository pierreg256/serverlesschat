//
//  PGTMessage.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 26/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTMessage.h"

@implementation PGTMessage

-(id) init{
    if (self = [super init]){
        self.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

@end

@implementation PGTMessageOut

+ (NSString *)dynamoDBTableName {
    return @"serverless_outbox";
}

+ (NSString *)hashKeyAttribute {
    return @"from";
}

@end

@implementation PGTMessageIn

+ (NSString *)dynamoDBTableName {
    return @"serverless_inbox";
}

+ (NSString *)hashKeyAttribute {
    return @"to";
}


@end