//
//  PGTContactsController.m
//  serverlesschat
//
//  Created by Pierre Gilot on 22/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTContactsController.h"
#import "FaceBookSDK.h"
#import "PGTContact.h"
#import <iAd/iAd.h>

@interface PGTContactsController ()
@property NSMutableArray* contacts;
@end

@implementation PGTContactsController

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    self.contacts = [[NSMutableArray alloc] initWithCapacity:20];
    
    return self;
}

-(void) refresh
{
    self.contacts = [[NSMutableArray alloc] initWithCapacity:20];
    [self.contacts addObject:[PGTContact me]];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
            NSLog(@"%@",friend);
            PGTContact* contact = [[PGTContact alloc] init];
            contact.firstName = friend.first_name;
            contact.lastName = friend.last_name;
            contact.fullName = friend.name;
            contact.idProvider = kidProviderFacebook;
            contact.idProviderID = friend.objectID;
            [self.contacts addObject:contact];
        }
        [self.tableView reloadData];
    }];
}

-(void)viewDidLoad
{
    self.canDisplayBannerAds = YES;

    [self refresh];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    return _contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    //NSDictionary<FBGraphUser>* friend = [_contacts objectAtIndex:indexPath.row];
    PGTContact* contact = [_contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = contact.fullName;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"false", @"redirect",
                            @"50", @"height",
                            @"normal", @"type",
                            @"50", @"width",
                            nil
                            ];

    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/picture", contact.idProviderID]
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSLog(@"%s - %@",__PRETTY_FUNCTION__,result[@"data"][@"url"]);
                              
                              UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:result[@"data"][@"url"]]]];
                              [cell.imageView setImage:profileImage];
                          }];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s - %@",__PRETTY_FUNCTION__,segue.identifier);
    ((PGTConversationController*)segue.destinationViewController).delegate = self;
    ((PGTConversationController*)segue.destinationViewController).recipient = [_contacts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
}

#pragma mark -- delegate methods
-(void)dismissConversationController:(PGTConversationController *)conversationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
