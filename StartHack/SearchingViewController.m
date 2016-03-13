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
#import <QuartzCore/QuartzCore.h>

@interface SearchingViewController () <TwilioConversationsClientDelegate, TWCConversationDelegate, TwilioAccessManagerDelegate, UIAlertViewDelegate>

@property NSString *identity;

@property (nonatomic) TwilioConversationsClient *conversationsClient;
@property (nonatomic) TWCIncomingInvite *incomingInvite;

@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIImageView *oval3;
@property (weak, nonatomic) IBOutlet UIImageView *oval4;
@property (weak, nonatomic) IBOutlet UILabel *searchingLable;
@property (nonatomic, strong) TwilioAccessManager *accessManager;

@end

@implementation SearchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 3.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    
    [self.oval1.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    rotationAnimation.duration = 3.8;
    [self.oval3.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: - M_PI * 2.0 ];
    rotationAnimation.duration = 3.3;
    [self.oval2.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    rotationAnimation.duration = 3.4;
    [self.oval4.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    CABasicAnimation *theAnimation;
    
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=1.0;
    theAnimation.repeatCount=HUGE_VALF;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.5];
    [self.searchingLable.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    
    
    [self listenForInvites];
    
    
}

- (void)listenForInvites {
    /* TWCLogLevelDisabled, TWCLogLevelError, TWCLogLevelWarning, TWCLogLevelInfo, TWCLogLevelDebug, TWCLogLevelVerbose  */
    [TwilioConversationsClient setLogLevel:TWCLogLevelError];
    
    if (!self.conversationsClient) {
        
      
        [self retrieveAccessTokenfromServer];
    }
}

-(void) retrieveAccessTokenfromServer {
    PFUser *user = [PFUser currentUser];
    NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *tokenEndpoint = @"http://murmuring-everglades-87090.herokuapp.com/token.php";
    NSString *urlString = [NSString stringWithFormat:tokenEndpoint, identifierForVendor];
    // Make JSON request to server
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    if (jsonResponse) {
        NSError *jsonError;
        NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:jsonResponse
                                                                      options:kNilOptions
                                                                        error:&jsonError];
        // Handle response from server
        if (!jsonError) {
            self.identity = tokenResponse[@"identity"];
            user[@"twilioIdentity"] = self.identity;
            [user saveInBackground];
            self.accessManager = [TwilioAccessManager accessManagerWithToken:tokenResponse[@"token"] delegate:self];
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
                                                                                                                            @"contents" : @{@"en": [NSString stringWithFormat:@"Someone needs your help. Open the App now to translate."]},
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
            
        }
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
    
    [self.navigationController pushViewController:add animated:NO];
    
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
