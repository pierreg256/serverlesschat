//
//  PGTContact.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 26/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceBookSDK.h"
#import "DynamoDB.h"

#define kidProviderFacebook @"FACEBOOK"

#define kKeyFirstName     @"firstName"
#define kKeyLastName      @"lastName"
#define kKeyFullName      @"fullName"
#define kKeyIdProvider    @"idProvider"
#define kKeyIdProviderID  @"idProviderID"
#define kKeyLocalID       @"localID"
#define kKeyAPSToken      @"SNSToken"

@interface PGTMapping : AWSDynamoDBObjectModel <AWSDynamoDBModeling>
@property (strong, nonatomic) NSString* idProviderID;
@property (strong, nonatomic) NSString* localID;
@property (strong, nonatomic) NSString* idProvider;
@end


@interface PGTContact : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* idProvider;
@property (strong, nonatomic) NSString* idProviderID;
@property (strong, nonatomic) NSString* localID;
@property (strong, nonatomic) NSString* SNSToken;


+(PGTContact*) me;
+(void)updateMeWithFacebookUser:(NSDictionary<FBGraphUser>*)fbUser apsToken:(NSString*)token andCognitoID:(NSString*)cognitoID;

//-(void)setValue:(id)value forKey:(NSString *)key;
//-(id)getValueForKey:(NSString*)key;

//-(NSString*)JSONDescription;


@end
