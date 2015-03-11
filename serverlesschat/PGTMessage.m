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
        self.timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000000];
        self.to = @[];
        self.id = [[NSUUID UUID] UUIDString];
    }
    return self;
}


-(void)addRecipient:(NSString *)recipient
{
    NSMutableArray* rec = [NSMutableArray arrayWithArray:self.to];
    [rec addObject:recipient];
    self.to = rec;
}

-(NSDictionary*)toNSDictionary
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__,[[self class] propertyKeys]);
    NSMutableDictionary* res = [[NSMutableDictionary alloc] initWithCapacity:10];
    
        [[[self class] propertyKeys] enumerateObjectsUsingBlock:^(NSString* obj, BOOL *stop) {
            [res setObject:[self valueForKey:obj] forKey:obj];
        }];
    return res;
}

@end

@implementation PGTMessageOut

+ (NSString *)dynamoDBTableName {
    return @"serverless_outbox";
}

+ (NSString *)hashKeyAttribute {
    return @"from";
}

+ (NSString*)rangeKeyAttribute {
    return @"timestamp";
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