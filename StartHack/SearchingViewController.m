//
//  SearchingViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "SearchingViewController.h"
#import <Parse/Parse.h>
#import <TwilioConversationsClient/TwilioConversationsClient.h>
#import "AppDelegate.h"
#import "ConversationViewController.h"

@interface SearchingViewController () <TwilioConversationsClientDelegate, TWCConversationDelegate, TwilioAccessManagerDelegate, UIAlertViewDelegate>

@property NSString *identity;

@property (nonatomic) TwilioConversationsClient *conversationsClient;
@property (nonatomic) TWCIncomingInvite *incomingInvite;

@property (nonatomic, strong) TwilioAccessManager *accessManager;

@end

@implementation SearchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    PFUser *user = [PFUser currentUser];
    
    
    
    
    // Token server endpoint URL
    NSString *urlString = @"http://murmuring-everglades-87090.herokuapp.com/token.php";
    
    // Make JSON request to server
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    NSError *jsonError;
    NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:jsonResponse
                                                                  options:kNilOptions
                                                                    error:&jsonError];
    
    // Handle response from server
    if (!jsonError) {
        self.identity = tokenResponse[@"identity"];
        user[@"twilioIdentity"] = self.identity;
        [user saveInBackground];
        NSLog(@"Token found: %@", tokenResponse[@"token"]);
       //  Create an AccessManager to manage our Access Token
//        self.accessManager = [TwilioAccessManager accessManagerWithToken:tokenResponse[@"token"]
//                                                                delegate:self];
//        
//        // Create a Conversations Client and connect to Twilio's backend.
//        self.conversationsClient =
//        [TwilioConversationsClient conversationsClientWithAccessManager:self.accessManager
//                                                               delegate:self];
//        [self.conversationsClient listen];
        
        NSString *accessToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTS2MxMjZhMDBhOGY3NjE2YTkyYzA2ZGMxNjg1OGEwYzA5LTE0NTc3OTUxMTciLCJpc3MiOiJTS2MxMjZhMDBhOGY3NjE2YTkyYzA2ZGMxNjg1OGEwYzA5Iiwic3ViIjoiQUNkMzE3ZjRiMzkzNzk3NzQ0OTM4NzdjYzgyNzZkNmUyOSIsImV4cCI6MTQ1Nzc5ODcxNywiZ3JhbnRzIjp7ImlkZW50aXR5IjoicXVpY2tzdGFydCIsInJ0YyI6eyJjb25maWd1cmF0aW9uX3Byb2ZpbGVfc2lkIjoiVlM3NGUzNDU4ODQzN2U2NDkwMzY1YjExNDk1ZTk2NTgxNiJ9fX0.MFlQYPeLvPRtjLm5E7R6nsQNLJYMtVcdaFiwZ2tNfX0";
                self.accessManager = [TwilioAccessManager accessManagerWithToken:accessToken delegate:self];
                self.conversationsClient = [TwilioConversationsClient conversationsClientWithAccessManager:self.accessManager
                                                                                                  delegate:self];
                [self.conversationsClient listen];
        
        
        PFObject *conversation = [PFObject objectWithClassName:@"Conversations"];
        conversation[@"user"] = user;
        [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"languages" containsAllObjectsInArray:@[self.firstLanguage, self.secondLanguage]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %d scores.", objects.count);
                    // Do something with the found objects
                    for (PFObject *object in objects) {
                        NSLog(@"%@", object.objectId);
                        NSDictionary *data = @{@"conversationId" : conversation.objectId, @"twilioId":self.identity};
                        if (object[@"pushID"]) {
                            [[(AppDelegate *)[[UIApplication sharedApplication] delegate] oneSignal] postNotification:@{
                                                                                                                        @"contents" : @{@"en": [NSString stringWithFormat:@"Hilfe!"]},
                                                                                                                        @"include_player_ids": @[object[@"pushID"]],
                                                                                                                        @"data": data
                                                                                                                        }];
                        }
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }];
        
        /* See the "Working with Conversations" guide for instructions on implementing
         a TwilioConversationsClientDelegate */
    } else {
        NSLog(@"error fetching token from server");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TwilioConversationsClientDelegate
/* This method is invoked when an attempt to connect to Twilio and listen for Converation invites has succeeded */
- (void)conversationsClientDidStartListeningForInvites:(TwilioConversationsClient *)conversationsClient {
    NSLog(@"Now listening for Conversation invites...");
    
//    self.listeningStatusLabel.text = @"Listening for Invites";
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.listeningStatusLabel.hidden = YES;
//        self.inviteeLabel.hidden = NO;
//        self.inviteeIdentityField.hidden = NO;
//        self.createConversationButton.hidden = NO;
//    });
}

/* This method is invoked when an attempt to connect to Twilio and listen for Converation invites has failed */
- (void)conversationsClient:(TwilioConversationsClient *)conversationsClient didFailToStartListeningWithError:(NSError *)error {
    NSLog(@"Failed to listen for Conversation invites: %@", error);
    
//    self.listeningStatusLabel.text = @"Failed to start listening for Invites";
}

/* This method is invoked when the SDK stops listening for Conversations invites */
- (void)conversationsClientDidStopListeningForInvites:(TwilioConversationsClient *)conversationsClient error:(NSError *)error {
    if (!error) {
        NSLog(@"Successfully stopped listening for Conversation invites");
        self.conversationsClient = nil;
    } else {
        NSLog(@"Stopped listening for Conversation invites (error): %ld", (long)error.code);
    }
}

/* This method is invoked when an incoming Conversation invite is received */
- (void)conversationsClient:(TwilioConversationsClient *)conversationsClient didReceiveInvite:(TWCIncomingInvite *)invite {
    NSLog(@"Conversations invite received: %@", invite);
    
    /*
     In this example we don't allow you to accept an invite while:
     1. A conversation is already in progress.
     2. Another invite is already being presented to the user.
     If you wish to accept an invite during a conversation, end the active conversation first and then accept the new invite.
     */
    
//    if (self.incomingInvite || self.navigationController.visibleViewController != self) {
//        [invite reject];
//        return;
//    }
    
    self.incomingInvite = invite;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    ConversationViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"Conversation"];
    
    add.incomingInvite = self.incomingInvite;
    add.client = self.conversationsClient;
    
    [self.navigationController pushViewController:add animated:YES];
    
//    NSString *incomingFrom = [NSString stringWithFormat:@"Incoming invite from %@", invite.from];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:incomingFrom
//                                                       delegate:self
//                                              cancelButtonTitle:@"Reject"
//                                              otherButtonTitles:@"Accept", nil];
//    [alertView show];
//    self.incomingAlert = alertView;
}

- (void)conversationsClient:(TwilioConversationsClient *)conversationsClient inviteDidCancel:(TWCIncomingInvite *)invite
{
//    [self.incomingAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.incomingInvite = nil;
}

#pragma mark -  TwilioAccessManagerDelegate

- (void)accessManagerTokenExpired:(TwilioAccessManager *)accessManager {
    NSLog(@"Token expired. Please update access manager with new token.");
}

- (void)accessManager:(TwilioAccessManager *)accessManager error:(NSError *)error {
    NSLog(@"AccessManager encountered an error : %ld", (long)error.code);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
