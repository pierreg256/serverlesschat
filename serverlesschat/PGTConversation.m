//
//  PGTConversation.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 09/03/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTConversation.h"
#import "PGTContact.h"

@interface PGTConversation ()

@property (nonatomic, strong) NSMutableArray* messages;
@property (nonatomic, strong) NSFileWrapper* fileWrapper;

@end

@implementation PGTConversationMetadata

@end

@implementation PGTConversationEntry

-(NSString*)description
{
    return [[self fileURL] lastPathComponent];
}

@end

@implementation PGTConversation

+(void)handleNewMessage:(PGTMessageIn *)message
{
    // define the local root first:
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* localRoot = [[paths objectAtIndex:0] URLByAppendingPathComponent:[[PGTContact me].localID stringByReplacingOccurrencesOfString:@":" withString:@"-"] isDirectory:YES];
    
    // first let's try and identify the conversation ID
    NSString* conversationID = message.conversationID ? message.conversationID : @"dead-letter-queue";
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, conversationID);
    
    // now find the conversation, if it esists
    NSURL* conversationURL = [[localRoot URLByAppendingPathComponent:conversationID] URLByAppendingPathExtension:@"slc"];
    
    PGTConversation * conversation = [[PGTConversation alloc] initWithFileURL:conversationURL];
    [conversation openWithCompletionHandler:^(BOOL success) {
        
        // Check status
        if (!success) {
            NSLog(@"Failed to open %@", conversationURL);
            return;
        }
        
        PGTConversationMetadata* conversationMetadata = conversation.metadata;
        NSURL* conversationURL = conversation.fileURL;
        //UIDocumentState conversationState = conversation.documentState;
        //NSFileVersion* conversationVersion = conversation.;
        
        NSLog(@"%s - loaded file : %@", __PRETTY_FUNCTION__, [conversationURL lastPathComponent]);
    }];
}

-(id)init
{
    NSLog(@"%s - ",__PRETTY_FUNCTION__);
    if (self = [super init]) {
        //        self.conversationID = [[NSUUID UUID] UUIDString];
        self.messages = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(NSUInteger)count{
    return self.messages.count;
}

-(void)addMessage:(PGTMessage *)message
{
    [self.messages addObject:message];
    [self.messages sortUsingComparator:^NSComparisonResult(PGTMessage* msg1, PGTMessage* msg2) {
        return [msg1.timestamp compare:msg2.timestamp];
    }];
}

#pragma mark - UIDocument primitives
- (void)encodeObject:(id<NSCoding>)object toWrappers:(NSMutableDictionary *)wrappers preferredFilename:(NSString *)preferredFilename {
    @autoreleasepool {
        NSMutableData * data = [NSMutableData data];
        NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:object forKey:@"data"];
        [archiver finishEncoding];
        NSFileWrapper * wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
        [wrappers setObject:wrapper forKey:preferredFilename];
    }
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSLog(@"%s - ", __PRETTY_FUNCTION__);
    
    if (self.metadata == nil) {
        return nil;
    }
    
    NSMutableDictionary * wrappers = [NSMutableDictionary dictionary];
    [self encodeObject:self.metadata toWrappers:wrappers preferredFilename:@"metadata"];
    
    NSFileWrapper * fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    
    return fileWrapper;
}

- (id)decodeObjectFromWrapperWithPreferredFilename:(NSString *)preferredFilename {
    
    NSFileWrapper * fileWrapper = [self.fileWrapper.fileWrappers objectForKey:preferredFilename];
    if (!fileWrapper) {
        NSLog(@"Unexpected error: Couldn't find %@ in file wrapper!", preferredFilename);
        return nil;
    }
    
    NSData * data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver * unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    return [unarchiver decodeObjectForKey:@"data"];
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    
    self.fileWrapper = (NSFileWrapper *) contents;
    
    // The rest will be lazy loaded...
    self.metadata = nil;
    
    return YES;
    
}

- (PGTConversationMetadata *)metadata {
    if (_metadata == nil) {
        if (self.fileWrapper != nil) {
            //NSLog(@"Loading metadata for %@...", self.fileURL);
            self.metadata = [self decodeObjectFromWrapperWithPreferredFilename:@"metadata"];
        } else {
            self.metadata = [[PGTConversationMetadata alloc] init];
        }
    }
    return _metadata;
}


@end
