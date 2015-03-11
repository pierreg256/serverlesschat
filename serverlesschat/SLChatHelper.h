//
//  SLChatHelper.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 26/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGTMessage.h"
@interface SLChatHelper : NSObject

+(void)updateProfile;
+(void)updateDeviceMapping;

+(void)sendMessage:(PGTMessageOut*)message;

+(void)fetchMessagesWithCompletionHandler:(void (^)(NSArray* result))completionHandler;
@end
