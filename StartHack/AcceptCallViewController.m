//
//  AcceptCallViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "AcceptCallViewController.h"
#import <Parse/Parse.h>
#import <TwilioConversationsClient/TwilioConversationsClient.h>
#import <AVFoundation/AVFoundation.h>
#import "ConversationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AcceptCallViewController () <TwilioConversationsClientDelegate, TWCConversationDelegate, TwilioAccessManagerDelegate, UIAlertViewDelegate>

@property NSString *identity;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoContainer;
@property (weak, nonatomic) IBOutlet UIView *localVideoContainer;

@property (nonatomic) TwilioConversationsClient *conversationsClient;
@property (nonatomic) TWCIncomingInvite *incomingInvite;

@property (nonatomic, strong) TwilioAccessManager *accessManager;

@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIImageView *oval3;
@property (weak, nonatomic) IBOutlet UIImageView *oval4;
@property (weak, nonatomic) IBOutlet UILabel *searchingLable;

@end

@implementation AcceptCallViewController

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
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Conversations"];
    [query whereKey:@"objectId" equalTo:self.conversationId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            // The find succeeded.
            if (object[@"translator"]) {
                 [self.navigationController popViewControllerAnimated:YES];
                
            }
            else  {
                object[@"translator"] = [PFUser currentUser];
                [object saveInBackground];
                [self listenForInvites];
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
   }

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
        /* This ViewController is being loaded to present an outgoing Conversation request */
    
}

- (void)listenForInvites {
    /* TWCLogLevelDisabled, TWCLogLevelError, TWCLogLevelWarning, TWCLogLevelInfo, TWCLogLevelDebug, TWCLogLevelVerbose  */
    [TwilioConversationsClient setLogLevel:TWCLogLevelError];
    
    if (!self.conversationsClient) {
        
     
        [self retrieveAccessTokenfromServer];
    }
}


-(void) retrieveAccessTokenfromServer {
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
            NSLog(tokenResponse[@"identity"]);
            self.accessManager = [TwilioAccessManager accessManagerWithToken:tokenResponse[@"token"] delegate:self];
            self.conversationsClient = [TwilioConversationsClient conversationsClientWithAccessManager:self.accessManager
                                                                                              delegate:self];
            [self.conversationsClient listen];
            
            
            
        }
    }
}

- (void)conversationsClientDidStartListeningForInvites:(TwilioConversationsClient *)conversationsClient {
    NSLog(@"Now listening for Conversation invites...");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    ConversationViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"Conversation"];
    
    add.inviteeIdentity = self.inviteeIdentity;
    add.client = self.conversationsClient;
    
    [self.navigationController pushViewController:add animated:NO];
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
