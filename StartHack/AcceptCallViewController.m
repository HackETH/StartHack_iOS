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

@interface AcceptCallViewController () <TWCConversationDelegate, TWCParticipantDelegate, TWCLocalMediaDelegate, TWCVideoTrackDelegate,TwilioConversationsClientDelegate, TWCConversationDelegate, TwilioAccessManagerDelegate, UIAlertViewDelegate>

@property NSString *identity;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoContainer;
@property (weak, nonatomic) IBOutlet UIView *localVideoContainer;

@property TwilioAccessManager *accessManager;
@property TwilioConversationsClient *conversationsClient;
@property (nonatomic, strong) TWCLocalMedia *localMedia;
@property (nonatomic, strong) TWCCameraCapturer *camera;
@property (nonatomic, strong) TWCConversation *conversation;
@property (nonatomic, strong) TWCOutgoingInvite *outgoingInvite;

@end

@implementation AcceptCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* LocalMedia represents our local camera and microphone (media) configuration */
    self.localMedia = [[TWCLocalMedia alloc] initWithDelegate:self];
    
#if !TARGET_IPHONE_SIMULATOR
    /* Microphone is enabled by default, to enable Camera, we first create a Camera capturer */
    self.camera = [self.localMedia addCameraTrack];
#else
    self.localVideoContainer.hidden = YES;
    self.pauseButton.enabled = NO;
    self.flipCameraButton.enabled = NO;
#endif
    
    /*
     We attach a view to display our local camera track immediately.
     You could also wait for localMedia:addedVideoTrack to attach a view or add a renderer.
     */
    if (self.camera) {
        [self.camera.videoTrack attach:self.localVideoContainer];
        self.camera.videoTrack.delegate = self;
    }
    
    /* For this demonstration, we always use Speaker audio output (vs. TWCAudioOutputReceiver) */
    [TwilioConversationsClient setAudioOutput:TWCAudioOutputSpeaker];
    
    
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Conversations"];
    [query whereKey:@"objectId" equalTo:self.conversationId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            // The find succeeded.
            if (object[@"translator"]) {
                
                
            }
            else {
                object[@"translator"] = user;
                [object saveInBackground];
                
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
                    // Create an AccessManager to manage our Access Token
//                    self.accessManager = [TwilioAccessManager accessManagerWithToken:tokenResponse[@"token"]
//                                                                            delegate:self];
                    NSString *accessToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTS2MxMjZhMDBhOGY3NjE2YTkyYzA2ZGMxNjg1OGEwYzA5LTE0NTc3OTUxMTciLCJpc3MiOiJTS2MxMjZhMDBhOGY3NjE2YTkyYzA2ZGMxNjg1OGEwYzA5Iiwic3ViIjoiQUNkMzE3ZjRiMzkzNzk3NzQ0OTM4NzdjYzgyNzZkNmUyOSIsImV4cCI6MTQ1Nzc5ODcxNywiZ3JhbnRzIjp7ImlkZW50aXR5IjoicXVpY2tzdGFydCIsInJ0YyI6eyJjb25maWd1cmF0aW9uX3Byb2ZpbGVfc2lkIjoiVlM3NGUzNDU4ODQzN2U2NDkwMzY1YjExNDk1ZTk2NTgxNiJ9fX0.MFlQYPeLvPRtjLm5E7R6nsQNLJYMtVcdaFiwZ2tNfX0";
                    self.accessManager = [TwilioAccessManager accessManagerWithToken:accessToken delegate:self];
                    
                    [self.conversationsClient listen];
                    
                    // Create a Conversations Client and connect to Twilio's backend.
                    self.conversationsClient =
                    [TwilioConversationsClient conversationsClientWithAccessManager:self.accessManager
                                                                           delegate:self];
                    [self.conversationsClient listen];
                    [self sendConversationInvite];
                    
                }
                
            }
            // Do something with the found objects
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
        /* This ViewController is being loaded to present an outgoing Conversation request */
        [self sendConversationInvite];
    
}

- (void)sendConversationInvite
{
    if (self.conversationsClient) {
        /* The createConversation method attempts to create and connect to a Conversation. The 'localStatusChanged' delegate method can be used to track the success or failure of connecting to the newly created Conversation.
         */
        self.outgoingInvite = [self.conversationsClient inviteToConversation:self.twilioId
                                                     localMedia:self.localMedia
                                                        handler:[self acceptHandler]];
    }
}

- (void)updateViewConstraints
{
    [self.view updateConstraints];
    
    TWCVideoTrack *cameraTrack = self.camera.videoTrack;
    if (cameraTrack && cameraTrack.videoDimensions.width > 0 && cameraTrack.videoDimensions.height > 0) {
        CMVideoDimensions dimensions = self.camera.videoTrack.videoDimensions;
        
        if (dimensions.width > 0 && dimensions.height > 0) {
            CGRect boundingRect = CGRectMake(0, 0, 160, 160);
            CGRect fitRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(dimensions.width, dimensions.height), boundingRect);
            CGSize fitSize = fitRect.size;
//            self.localVideoWidthConstraint.constant = fitSize.width;
//            self.localVideoHeightConstraint.constant = fitSize.height;
        }
    }
}

- (TWCInviteAcceptanceBlock)acceptHandler
{
    return ^(TWCConversation * _Nullable conversation, NSError * _Nullable error) {
        if (conversation) {
            conversation.delegate = self;
            self.conversation = conversation;
        }
        else {
            NSLog(@"Invite failed with error: %@", error);
            [self dismissConversation];
        }
    };
}

- (void)dismissConversation
{
    self.localMedia = nil;
    self.conversation = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (TWCLocalMedia *)setupLocalMedia
{
    // Create LocalMedia with a camera track and no microphone track
    TWCLocalMedia *localMedia = [[TWCLocalMedia alloc] initWithDelegate:self];
    [localMedia addCameraTrack];
    return localMedia;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TWCConversationDelegate

- (void)conversation:(TWCConversation *)conversation didConnectParticipant:(TWCParticipant *)participant
{
    NSLog(@"Participant connected: %@", [participant identity]);
    
    participant.delegate = self;
}

- (void)conversation:(TWCConversation *)conversation didFailToConnectParticipant:(TWCParticipant *)participant error:(NSError *)error
{
    NSLog(@"Participant failed to connect: %@ with error: %@", [participant identity], error);
    
    [self.conversation disconnect];
}

- (void)conversation:(TWCConversation *)conversation didDisconnectParticipant:(TWCParticipant*)participant
{
    NSLog(@"Participant disconnected: %@", [participant identity]);
    
    if ([self.conversation.participants count] <= 1) {
        [self.conversation disconnect];
    }
}

- (void)conversationEnded:(TWCConversation *)conversation
{
    [self dismissConversation];
}

- (void)conversationEnded:(TWCConversation *)conversation error:(NSError *)error
{
    [self dismissConversation];
}

#pragma mark - TWCLocalMediaDelegate

- (void)localMedia:(TWCLocalMedia *)media didAddVideoTrack:(TWCVideoTrack *)videoTrack
{
    NSLog(@"Local video track added: %@", videoTrack);
}

- (void)localMedia:(TWCLocalMedia *)media didRemoveVideoTrack:(TWCVideoTrack *)videoTrack
{
    NSLog(@"Local video track removed: %@", videoTrack);
    
    /* You do not need to call [videoTrack detach:] here, your view will be detached once this call returns. */
    
    self.camera = nil;
}

#pragma mark - TWCParticipantDelegate

- (void)participant:(TWCParticipant *)participant addedVideoTrack:(TWCVideoTrack *)videoTrack
{
    NSLog(@"Video added for participant: %@", [participant identity]);
    
    [videoTrack attach:self.remoteVideoContainer];
    videoTrack.delegate = self;
}

- (void)participant:(TWCParticipant *)participant removedVideoTrack:(TWCVideoTrack *)videoTrack
{
    NSLog(@"Video removed for participant: %@", [participant identity]);
    
    /* You do not need to call [videoTrack detach:] here, your view will be detached once this call returns. */
}

- (void)participant:(TWCParticipant *)participant addedAudioTrack:(TWCAudioTrack *)audioTrack
{
    NSLog(@"Audio added for participant: %@", participant.identity);
}

- (void)participant:(TWCParticipant *)participant removedAudioTrack:(TWCAudioTrack *)audioTrack
{
    NSLog(@"Audio removed for participant: %@", participant.identity);
}

- (void)participant:(TWCParticipant *)participant enabledTrack:(TWCMediaTrack *)track
{
    NSLog(@"Enabled track: %@", track);
}

- (void)participant:(TWCParticipant *)participant disabledTrack:(TWCMediaTrack *)track
{
    NSLog(@"Disabled track: %@", track);
}

#pragma mark - TWCVideoTrackDelegate

- (void)videoTrack:(TWCVideoTrack *)track dimensionsDidChange:(CMVideoDimensions)dimensions
{
    NSLog(@"Dimensions changed to: %d x %d", dimensions.width, dimensions.height);
    
    [self.view setNeedsUpdateConstraints];
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
