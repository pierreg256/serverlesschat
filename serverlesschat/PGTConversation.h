//
//  PGTConversation.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 09/03/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGTMessage.h"

@interface PGTConversation : NSObject

@property (nonatomic, strong) NSString* conversationID;
@property (nonatomic, readonly) NSUInteger count;

-(void)addMessage:(PGTMessage*)message;

@end
