//
//  AppDelegate.h
//  serverlesschat
//
//  Created by Pierre Gilot on 22/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWSCore.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) AWSCognitoCredentialsProvider* credentialsProvider;

@end

