//
//  PGTMessage.h
//  serverlesschat
//
//  Created by Gilot, Pierre on 26/02/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamoDB.h"

@interface PGTMessage : AWSDynamoDBObjectModel

@property (nonatomic, strong) NSString* from;
@property (nonatomic, strong) NSArray* to;
@property (nonatomic, strong) NSString* body;
@property (nonatomic, strong) NSNumber* timestamp;

@end

@interface PGTMessageOut : PGTMessage <AWSDynamoDBModeling>
@end

@interface PGTMessageIn : PGTMessage <AWSDynamoDBModeling>
@end