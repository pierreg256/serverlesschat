//
//  PGTContact.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 26/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTContact.h"
#import "FaceBookSDK.h"

//@interface PGTContact ()
//@property (nonatomic, strong) NSDictionary* attributes;
//@end

@implementation PGTMapping
+ (NSString *)dynamoDBTableName {
    return @"serverless_id_mappings";
}

+ (NSString *)hashKeyAttribute {
    return @"idProviderID";
}

@end

@implementation PGTContact

//-(id)init
//{
//    if (self == [super init]){
//        self.attributes = [[NSMutableDictionary alloc] initWithCapacity:5];
//    }
//    return self;
//}

static PGTContact* myself;

+(PGTContact*) me
{
    if (!myself) {
        myself = [[PGTContact alloc] init];
        
        myself.firstName = @"Test";
        myself.lastName = @"User";
        myself.fullName = @"Test User";
    }
    
    return myself;
}

+(void)updateMeWithFacebookUser:(NSDictionary<FBGraphUser> *)fbUser apsToken:(NSString*)token andCognitoID:(NSString *)cognitoID
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, fbUser);
    [PGTContact me];

    
    myself.firstName =  fbUser.first_name ;
    myself.lastName = fbUser.last_name;
    myself.fullName = fbUser.name;
    myself.idProvider = kidProviderFacebook;
    myself.idProviderID = fbUser.objectID;
    myself.localID =  cognitoID;
    if (token.length>0) {
        myself.SNSToken = token;
    } else {
        myself.SNSToken = nil;
    }
    
    NSLog(@"%s - %@",__PRETTY_FUNCTION__, myself);
}

//-(void)setValue:(id)value forKey:(NSString *)key
//{
//    [self.attributes setValue:value forKey:key];
//}
//
//-(id)getValueForKey:(NSString*)key
//{
//    return [self.attributes valueForKey:key];
//}


//-(NSString*)JSONDescription
//{
//    NSError* error;
//    NSData* data = [NSJSONSerialization dataWithJSONObject:self.attributes options:NSJSONWritingPrettyPrinted error:&error];
//    
//    if(error){
//        NSLog(@"%s - %@",__PRETTY_FUNCTION__, error);
//        return @"";
//    }
//
//    return [NSString stringWithUTF8String:[data bytes]];
//}

#pragma mark -- dynamo db modelling methods
+ (NSString *)dynamoDBTableName {
    return @"serverless_profile";
}

+ (NSString *)hashKeyAttribute {
    return @"localID";
}

@end
