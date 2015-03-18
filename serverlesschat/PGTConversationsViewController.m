//
//  PGTConversationsViewController.m
//  serverlesschat
//
//  Created by Gilot, Pierre on 11/03/2015.
//  Copyright (c) 2015 Pierre Gilot. All rights reserved.
//

#import "PGTConversationsViewController.h"
#import "PGTConversation.h"
#import "PGTContact.h"

@interface PGTConversationsViewController ()

@property (nonatomic, strong) NSURL* localRoot;
@property (nonatomic, strong) PGTConversation* selConversation;
@property (nonatomic, strong) NSMutableArray* conversationEntries;

- (void)addOrUpdateEntryWithURL:(NSURL *)fileURL metadata:(PGTConversationMetadata *)metadata ;
- (NSUInteger)indexOfEntryWithFileURL:(NSURL*)fileURL;

@end

@implementation PGTConversationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSError* error;
    [[NSFileManager defaultManager] createDirectoryAtURL:[self localRoot] withIntermediateDirectories:YES attributes:nil error:&error];
    self.conversationEntries = [[NSMutableArray alloc] initWithCapacity:10];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURL *)localRoot {
    NSArray * paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return [[paths objectAtIndex:0] URLByAppendingPathComponent:[[PGTContact me].localID stringByReplacingOccurrencesOfString:@":" withString:@"-"] isDirectory:YES];
}

- (NSURL *)getDocURL:(NSString *)filename {
    return [[self.localRoot URLByAppendingPathComponent:filename] URLByAppendingPathExtension:@"slc"];
}

- (void)loadDocAtURL:(NSURL *)fileURL {
    
    // Open doc so we can read metadata
    PGTConversation * conversation = [[PGTConversation alloc] initWithFileURL:fileURL];
    [conversation openWithCompletionHandler:^(BOOL success) {
        
        // Check status
        if (!success) {
            NSLog(@"Failed to open %@", fileURL);
            return;
        }
        
        PGTConversationMetadata* conversationMetadata = conversation.metadata;
        NSURL* conversationURL = conversation.fileURL;
        //UIDocumentState conversationState = conversation.documentState;
        //NSFileVersion* conversationVersion = conversation.;
        
        NSLog(@"%s - loaded file : %@", __PRETTY_FUNCTION__, [conversationURL lastPathComponent]);
        
/*
        // Preload metadata on background thread
        PGTMetaData * metadata = doc.metadata;
        NSURL * fileURL = doc.fileURL;
        UIDocumentState state = doc.documentState;
        NSFileVersion * version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        NSLog(@"Loaded File URL: %@", [doc.fileURL lastPathComponent]);
*/
        // Close since we're done with it
        [conversation closeWithCompletionHandler:^(BOOL success) {
            
            // Check status
            if (!success) {
                NSLog(@"Failed to close %@", fileURL);
                // Continue anyway...
            }
            
            // Add to the list of files on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addOrUpdateEntryWithURL:conversationURL  metadata:conversationMetadata];
            });
        }];
    }];
    
}

-(NSUInteger)indexOfEntryWithFileURL:(NSURL *)fileURL
{
    __block int retval = -1;
    
    [self.conversationEntries enumerateObjectsUsingBlock:^(PGTConversationEntry* entry, NSUInteger idx, BOOL *stop) {
        if ([entry.fileURL isEqual:fileURL]) {
            retval = idx;
            *stop = YES;
        }
    }];
    return retval;
}

- (void)addOrUpdateEntryWithURL:(NSURL *)fileURL metadata:(PGTConversationMetadata *)metadata {
    
    int index = [self indexOfEntryWithFileURL:fileURL];
    
    // Not found, so add
    if (index == -1) {
        
        PGTConversationEntry * entry = [[PGTConversationEntry alloc] init];
        entry.fileURL = fileURL;
        entry.metadata = metadata;
        
        [self.conversationEntries addObject:entry];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(self.conversationEntries.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        
    }
    
    // Found, so edit
    else {
        
        PGTConversationEntry * entry = [_conversationEntries objectAtIndex:index];
        entry.metadata = metadata;
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
}


- (void)loadLocal {
    
    NSArray * localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.localRoot includingPropertiesForKeys:nil options:0 error:nil];
    NSLog(@"Found %lu local files.", (unsigned long)localDocuments.count);
    for (int i=0; i < localDocuments.count; i++) {
        
        NSURL * fileURL = [localDocuments objectAtIndex:i];
        if ([[fileURL pathExtension] isEqualToString:@"slc"]) {
            NSLog(@"Found local file: %@", fileURL);
            [self loadDocAtURL:fileURL];
        }
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)refresh {
    
    [self.conversationEntries removeAllObjects];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self loadLocal];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversationEntries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationCell" forIndexPath:indexPath];
    PGTConversationEntry* entry = [_conversationEntries objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = entry.metadata.name;
    cell.detailTextLabel.text = entry.description;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        PGTConversationEntry * entry = [_conversationEntries objectAtIndex:indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _selConversation = [[PGTConversation alloc] initWithFileURL:entry.fileURL];
        [_selConversation openWithCompletionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"conversation" sender:self];
            });
        }];
}


#pragma mark - view actions
-(IBAction)newConversation:(id)sender
{
    NSString* conversationID = [[NSUUID UUID] UUIDString];
    NSURL* url = [self getDocURL:conversationID];
    PGTConversation* newConversation = [[PGTConversation alloc] initWithFileURL:url];
    newConversation.metadata = [[PGTConversationMetadata alloc] init];
    newConversation.metadata.conversationID = conversationID;
    newConversation.metadata.name = @"New Conversation";
    newConversation.metadata.recipients = [[NSMutableArray alloc] initWithObjects:[PGTContact me], nil];
    
    [newConversation saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (!success)
        {
            NSLog(@"%s - Failed to create file at %@", __PRETTY_FUNCTION__, url);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addOrUpdateEntryWithURL:newConversation.fileURL metadata:newConversation.metadata];
            self.selConversation = newConversation;
            [self performSegueWithIdentifier:@"conversation" sender:self];
            
        });
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"conversation"]) {
        [((PGTConversationController*)segue.destinationViewController) setDelegate:self];
        ((PGTConversationController*)segue.destinationViewController).conversation = _selConversation;
    }
}

-(void)dismissConversationController:(PGTConversationController *)conversationController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
