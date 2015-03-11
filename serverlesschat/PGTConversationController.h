//
//  PGTConversationController.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 27/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGTContact.h"

@class PGTConversationController;

@protocol PGTConversationControllerDelegate <NSObject>

@required
-(void)dismissConversationController:(PGTConversationController*)conversationController;

@end

@interface PGTConversationController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton* btnBack;
@property (strong, nonatomic) IBOutlet UITextField* inputText;
@property (strong, nonatomic) IBOutlet UIButton* btnSend;

@property (strong, nonatomic) PGTContact* recipient;

@property (weak, nonatomic) id<PGTConversationControllerDelegate> delegate;

-(IBAction)backButtonClicked:(id)sender;
-(IBAction)sendButtonClicked:(id)sender;
@end
