//
//  PGTConversationController.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 27/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTConversationController.h"
#import "PGTMessage.h"
#import "SLChatHelper.h"

@interface PGTConversationController ()

@end

@implementation PGTConversationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)backButtonClicked:(id)sender
{
    if (self.delegate) {
        [self.delegate dismissConversationController:self];
    }
}

-(IBAction)sendButtonClicked:(id)sender
{
    PGTMessageOut* msg = [[PGTMessageOut alloc]init];
    //    [msg.to addObject:self.recipient.idProviderID];
    [msg addRecipient:self.recipient.idProviderID];
    msg.from = [PGTContact me].idProviderID;
    msg.body = self.inputText.text;
    
    [SLChatHelper sendMessage:msg];
}
@end
