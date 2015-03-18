//
//  PGTConversationsViewController.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 11/03/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGTConversationController.h"


@interface PGTConversationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PGTConversationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;


-(IBAction) newConversation:(id)sender;



@end
