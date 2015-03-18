//
//  PGTConversation.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 09/03/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGTMessage.h"
#import "MTLModel+NSCoding.h"


@interface PGTConversationMetadata : MTLModel

@property (nonatomic, strong) NSString* conversationID;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, readonly) NSUInteger msgCount;
@property (nonatomic, strong) NSMutableArray* recipients;

@end

@interface PGTConversationEntry : NSObject

@property (nonatomic, strong) NSURL* fileURL;
@property (nonatomic, strong) PGTConversationMetadata* metadata;

@end

@interface PGTConversation : UIDocument

@property (nonatomic, strong) PGTConversationMetadata* metadata;


+(void)handleNewMessage:(PGTMessageIn*)message;
-(void)addMessage:(PGTMessage*)message;

@end
