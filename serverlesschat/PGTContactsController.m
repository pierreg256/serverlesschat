//
//  PGTContactsController.m
//  serverlesschat
//
//  Created by Pierre Gilot on 22/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTContactsController.h"
#import "FaceBookSDK.h"

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
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
            NSLog(@"%@",friend);
            [self.contacts addObject:friend];
        }
        [self.tableView reloadData];
    }];
}

-(void)viewDidLoad
{
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
    NSDictionary<FBGraphUser>* friend = [_contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = friend.name;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"false", @"redirect",
                            @"50", @"height",
                            @"normal", @"type",
                            @"50", @"width",
                            nil
                            ];

    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/picture", friend.objectID]
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

@end
