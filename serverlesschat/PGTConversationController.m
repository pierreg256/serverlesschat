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
#import "FaceBookSDK.h"

@interface PGTConversationController ()
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
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

-(IBAction)addButtonClicked:(id)sender
{
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

-(IBAction)sendButtonClicked:(id)sender
{
    PGTMessageOut* msg = [[PGTMessageOut alloc]init];
    //    [msg.to addObject:self.recipient.idProviderID];
    
    [self.conversation.metadata.recipients enumerateObjectsUsingBlock:^(PGTContact* obj, NSUInteger idx, BOOL *stop) {
        [msg addRecipient:obj.idProviderID];
    }];
    //[msg addRecipient:self.recipient.idProviderID];
    msg.from = [PGTContact me].idProviderID;
    msg.body = self.inputText.text;
    msg.conversationID = self.conversation.metadata.conversationID;
    
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, msg);
    
    [SLChatHelper sendMessage:msg];
}

#pragma mark - FB delegate methods
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        if ([text length]) {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, text.length > 0 ? text : @"<None>");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    NSLog(@"%s - <Cancelled>", __PRETTY_FUNCTION__);
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
