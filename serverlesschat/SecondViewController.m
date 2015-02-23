//
//  SecondViewController.m
//  serverlesschat
//
//  Created by Pierre Gilot on 22/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "SecondViewController.h"
#import "FaceBookSDK.h"
#import <iAd/iAd.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.canDisplayBannerAds = YES;
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
        }
    }];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"YOUR_MESSAGE_HERE"
     title:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSLog(@"%s - %@", __PRETTY_FUNCTION__, [resultURL query]);
//                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                 if (![urlParams valueForKey:@"request"]) {
//                     // User clicked the Cancel button
//                     NSLog(@"User canceled request.");
//                 } else {
//                     // User clicked the Send button
//                     NSString *requestID = [urlParams valueForKey:@"request"];
//                     NSLog(@"Request ID: %@", requestID);
//                 }
             }
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
