//
//  PGTConversation.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 09/03/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTConversation.h"

@interface PGTConversation ()

@property (nonatomic, strong) NSMutableArray* messages;

@end


@implementation PGTConversation


-(id)init
{
    if (self = [super init]) {
        self.conversationID = [[NSUUID UUID] UUIDString];
        self.messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(NSUInteger)count{
    return self.messages.count;
}

-(void)addMessage:(PGTMessage *)message
{
    [self.messages addObject:message];
    [self.messages sortUsingComparator:^NSComparisonResult(PGTMessage* msg1, PGTMessage* msg2) {
        return [msg1.timestamp compare:msg2.timestamp];
    }];
}

@end
