//
//  FirstViewController.m
//  serverlesschat
//
//  Created by Pierre Gilot on 22/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "FirstViewController.h"
#import "FaceBookSDK.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // Do any additional setup after loading the view, typically from a nib.
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:
                              @[@"public_profile", @"email", @"user_friends"]];
    loginView.delegate = self;
    
    loginView.center = self.view.center;
    [self.view addSubview:loginView];
    
    
    CGRect profileRect = CGRectMake(0, 0, screenWidth/2, screenWidth/2);
    CGPoint center = loginView.center;
    center.y -= (center.y/2);
    self.profilePictureView = [[FBProfilePictureView alloc] initWithFrame:profileRect];
    self.profilePictureView.center = center;
    [self.view addSubview:self.profilePictureView];
    
    CGRect labelRect = CGRectMake(0, 0, screenWidth/2, screenWidth/8);
    center = loginView.center;
    center.y += (center.y/2);
    self.statusLabel = [[UILabel alloc] initWithFrame:labelRect];
    self.statusLabel.center = center;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FB delegate methods
// Call method when user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.objectID;
//    self.nameLabel.text = user.name;
}

// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.statusLabel.text = @"You're logged in!";
}

// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
//    self.nameLabel.text = @"";
    self.statusLabel.text= @"You're not logged in!";
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user performs an action outside of you app to recover,
    // the SDK provides a message, you just need to surface it.
    // This handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
@end
