//
//  ConversationViewController.m
//  Twilio Video - Conversations Quickstart
//


#import "ConversationViewController.h"

#import "AppDelegate.h"
#import <TwilioConversationsClient/TwilioConversationsClient.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ConversationViewController () <TWCConversationDelegate, TWCParticipantDelegate, TWCLocalMediaDelegate, TWCVideoTrackDelegate>

@property (weak, nonatomic) IBOutlet UIView *remoteVideoContainer;
@property (weak, nonatomic) IBOutlet UIView *localVideoContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localVideoWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localVideoHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *flipCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;

@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIImageView *oval3;
@property (weak, nonatomic) IBOutlet UIImageView *oval4;
@property (weak, nonatomic) IBOutlet UILabel *searchingLable;

@property (nonatomic, strong) TWCLocalMedia *localMedia;
@property (nonatomic, strong) TWCCameraCapturer *camera;
@property (nonatomic, strong) TWCConversation *conversation;
@property (nonatomic, strong) TWCOutgoingInvite *outgoingInvite;
@property BOOL *firstCalled;

@end

@implementation ConversationViewController

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
    
    self.localVideoContainer.hidden = true;
    self.remoteVideoContainer.hidden = true;
    self.pauseButton.hidden = true;
    self.flipCameraButton.hidden = true;
    self.muteButton.hidden = true;
    self.hangupButton.hidden = true;

    /* For this demonstration, we always use Speaker audio output (vs. TWCAudioOutputReceiver) */
    [TwilioConversationsClient setAudioOutput:TWCAudioOutputSpeaker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.incomingInvite) {
        /* This ViewController is being loaded to present an incoming Conversation request */
        if ([_conversation disconnect]) NSLog(@"disconnected from active conversation");
        [self.incomingInvite acceptWithLocalMedia:self.localMedia
                                       completion:[self acceptHandler]];
    }
    else if ([self.inviteeIdentity length] > 0) {
        /* This ViewController is being loaded to present an outgoing Conversation request */
        [self sendConversationInvite];
    }
}

- (void)updateViewConstraints
{
    [self.view updateConstraints];

    TWCVideoTrack *cameraTrack = self.camera.videoTrack;
    if (cameraTrack && cameraTrack.videoDimensions.width > 0 && cameraTrack.videoDimensions.height > 0) {
        CMVideoDimensions dimensions = self.camera.videoTrack.videoDimensions;
        
        if (self.firstCalled) {
            self.localVideoContainer.hidden = false;
            self.remoteVideoContainer.hidden = false;
            self.pauseButton.hidden = false;
            self.flipCameraButton.hidden = false;
            self.muteButton.hidden = false;
            self.hangupButton.hidden = false;
            
        }
        else {
            self.firstCalled = TRUE;
            self.localVideoContainer.hidden = true;
            self.remoteVideoContainer.hidden = true;
            self.pauseButton.hidden = true;
            self.flipCameraButton.hidden = true;
            self.muteButton.hidden = true;
            self.hangupButton.hidden = true;
        }

        if (dimensions.width > 0 && dimensions.height > 0) {
            CGRect boundingRect = CGRectMake(0, 0, 160, 160);
            CGRect fitRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(dimensions.width, dimensions.height), boundingRect);
            CGSize fitSize = fitRect.size;
            self.localVideoWidthConstraint.constant = fitSize.width;
            self.localVideoHeightConstraint.constant = fitSize.height;
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

- (void)sendConversationInvite
{
    if (self.client) {
        /* The createConversation method attempts to create and connect to a Conversation. The 'localStatusChanged' delegate method can be used to track the success or failure of connecting to the newly created Conversation.
         */
        self.outgoingInvite = [self.client inviteToConversation:self.inviteeIdentity
                                                     localMedia:self.localMedia
                                                        handler:[self acceptHandler]];
    }
}

- (void)dismissConversation
{
    self.localMedia = nil;
    self.conversation = nil;
     [self.navigationController popViewControllerAnimated:YES];
     [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UI actions

- (IBAction)flipButtonClicked:(id)sender {
    if (self.conversation) {
        [self.camera flipCamera];
    }
}

- (void)updatePauseButton
{
    NSString *title = self.camera.videoTrack.enabled ? @"Pause" : @"Unpause";
   // [self.pauseButton setTitle:title forState:UIControlStateNormal];
}

- (IBAction)pauseButtonClicked:(id)sender {
    if (self.conversation) {
        self.camera.videoTrack.enabled = !self.camera.videoTrack.enabled;
        [self updatePauseButton];
    }
}

- (IBAction)muteButtonClicked:(id)sender {
    if (self.conversation) {
        self.conversation.localMedia.microphoneMuted = !self.conversation.localMedia.microphoneMuted;
       // [self.muteButton setTitle:self.conversation.localMedia.microphoneMuted? @"Unmute" : @"Mute" forState:UIControlStateNormal];
    }
}

- (IBAction)hangupButtonClicked:(id)sender {

    [self.conversation disconnect];
    [self.incomingInvite reject];
    [self.outgoingInvite cancel];
     [self.navigationController popViewControllerAnimated:YES];
     [self.navigationController popViewControllerAnimated:YES];
}

@end
