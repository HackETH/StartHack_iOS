//
//  CallViewController.m
//  StartHack
//
//  Created by Samuel Mueller on 21.07.16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//
#define withRating YES
#define allowRatingAfterSecs 1
#define giveUpAfterSecs 20

#import "CallViewController.h"
#import <Parse/Parse.h>
#import <OneSignal/OneSignal.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SelectTypeViewController.h"
#import "TranslatorMainViewController.h"
#import "ViewController.h"
#import "TranslatorMainViewController.h"
#import "RateViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface CallViewController ()
@property (nonatomic) TCDevice *phone;
@property () TCConnection *connection;
@property () bool alwaysReject;
@property () bool left;
@property () AVAudioPlayer *audioPlayer;
@property () bool isRequesting;
@property () bool silent;
@property () bool askForRating;
@end

@implementation CallViewController 



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _askForRating = NO;
    _silent = YES;
    _left = NO;
    _userIdsToConnectWith = [NSMutableArray array];
    _isRequesting = NO;
    if (!_token) {
        NSString *urlString = [NSString stringWithFormat:@"https://helpingvoice.herokuapp.com/token?client=%@", [PFUser currentUser].objectId];
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *error = nil;
        NSString *token = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        if (token == nil) {
            NSLog(@"Error retrieving token: %@", [error localizedDescription]);
        } else {
            _phone = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
            if (_needsHelp) {
                [self sendRequests];

            }else{
                [self makeCall];
            }
        }

    }else{
        _phone = [[TCDevice alloc] initWithCapabilityToken:_token delegate:self];
        if (_needsHelp) {
            [self sendRequests];

        }else{
            [self makeCall];
        }
    }
}
- (IBAction)toglleMute:(id)sender {
    if(self.connection.state == TCConnectionStateConnected){
        self.connection.muted = !self.connection.isMuted;
    }
}
-(void)enteredBackground{
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        
    }

    PFUser *user = [PFUser currentUser];
    if ([user[@"type"] isEqualToString:@"translator"]) {
        [self pop:2 viewControllersanimated:NO];
    }else{
        
        if (_isRequesting && _userIdsToConnectWith) {
            [self deleteNotificationsOnOtherDevices];

        }
        [self.navigationController popViewControllerAnimated:NO];

    }
}
- (IBAction)toggleLoud:(id)sender {
    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [session setActive: YES error:nil];
    AVAudioSessionPortDescription *routePort = session.currentRoute.outputs.firstObject;
    NSString *portType = routePort.portType;
    NSLog(portType);
    if (_silent) {
        [session  overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    } else {
        [session  overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
    }
    _silent = !_silent;
}

-(void)makeCall{
    [self.informationLabel setText:@"Waiting for call partner to answer phone!"];
    NSDictionary *params = @{@"To": [NSString stringWithFormat:@"client:%@",self.reachHere]};
    
    _connection = [_phone connect:params delegate:self];

}
-(void)connectionDidDisconnect:(TCConnection *)connection
{
    if (!_alwaysReject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self goBack];

        });
    }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self goBack];
                
            });
    }
    NSLog(@"Connection did disconnect, so went back");

}
-(void)goBackIfNotConnected{
    if (_isRequesting) {
        UIAlertController *alert  = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Please, try again", nil)  message:NSLocalizedString(@"No one answered your call", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {        [self goBack];
}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)sendRequests{
    _isRequesting = YES;
    [self performSelector:@selector(goBackIfNotConnected) withObject:nil afterDelay:giveUpAfterSecs];

    //´ [self.informationLabel setText:@"Requesting Translator... Don't close the app."];
    [_informationLabel setText:NSLocalizedString(@"Requesting Translator... Don't close the app.", @"")];
    NSError *error;
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    self.audioPlayer = [[AVAudioPlayer alloc]
                        initWithContentsOfURL:fileURL error:&error];
    _audioPlayer.numberOfLoops = 10000;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    PFObject *conversation = [PFObject objectWithClassName:@"Conversations"];
    conversation[@"user"] = [PFUser currentUser];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"languages" containsAllObjectsInArray:@[self.firstLanguage, self.secondLanguage]];
        [query orderByAscending:@"timesCalled"];
        [query setLimit:20];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                    NSDictionary *data = @{@"conversationId" : conversation.objectId,@"reachMeHere":  [PFUser currentUser].objectId,@"helpRequest": [NSNumber numberWithBool:true]};
                    if (object[@"pushID"]) {
                        [_userIdsToConnectWith addObject:object[@"pushID"]];
                        NSLog(@"%@",object[@"pushID"]);
                        [[(AppDelegate *)[[UIApplication sharedApplication] delegate] oneSignal] postNotification:@{
                                                                                                                    @"contents" : @{@"en": [NSString stringWithFormat:@"Someone needs your help via audio. Open the App now to translate."]},
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

- (IBAction)hangupButtonPressed:(id)sender
{
    if (_isRequesting && _userIdsToConnectWith) {
        [self deleteNotificationsOnOtherDevices];

    }
    if (_audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    [_connection disconnect];
    self.alwaysReject = YES;
    [self goBack];
}
-(void)connectionDidConnect:(TCConnection *)connection
{
    //Maybe???[_connection disconnect];
    _isRequesting = NO;
    [self performSelector:@selector(allowReporting) withObject:nil afterDelay:allowRatingAfterSecs];

    [self.informationLabel setText:NSLocalizedString(@"In Call", nil) ];
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        
    }
}
-(void)connection:(TCConnection *)connection didFailWithError:(NSError *)error
{
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        
    }
}
-(void)allowReporting{
    _askForRating = YES;
}
- (void) goBack{
    self.left = YES;
    PFUser *user = [PFUser currentUser];
    if (withRating  && _askForRating) {
        if ([user[@"type"] isEqualToString:@"translator"]) {
            if (_connection.parameters[@"To"]) {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                RateViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"TranslatorRatesUser"];
                add.userId = [_connection.parameters[@"To"] substringFromIndex:7] ;
                [self.navigationController pushViewController:add animated:NO];
            }else{
                [self pop:2 viewControllersanimated:YES];

            }
        }else{
            if (_connection.parameters[@"From"]) {
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                RateViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"UserRatesTranslator"];
                add.userId = [_connection.parameters[@"From"] substringFromIndex:7];
                [self.navigationController pushViewController:add animated:NO];

            }else{
                [self pop:1 viewControllersanimated:YES];
            }
        }
    }else{
        if ([user[@"type"] isEqualToString:@"translator"]) {
            // Check if the user allready selected languages
            [self pop:2 viewControllersanimated:YES];
            
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            
        }
    }
    
    
}

- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    //Übergangslösung da manchmal beim flüchtling nicht didconnect aufgerufen
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
        
    }
    NSLog(@"Incoming connection from: %@", [connection parameters][@"From"]);
    NSLog(@"with state as follows: stateIsBusy:%d needsHelp:%d alwaysRefect:%d",device.state == TCDeviceStateBusy,self.needsHelp,self.alwaysReject);
    if (device.state == TCDeviceStateBusy || !self.needsHelp || self.alwaysReject) {
        [connection reject];
    } else {
        connection.delegate = self;
        [connection accept];
        _connection = connection;
        [self deleteNotificationsOnOtherDevices];
    }
}

-(void)deleteNotificationsOnOtherDevices{
    if (_userIdsToConnectWith) {
        [[(AppDelegate *)[[UIApplication sharedApplication] delegate] oneSignal] postNotification:@{
                                                                                                    @"contents" : @{@"en": [NSString stringWithFormat:@"Somebody else helped already"]},       @"content_available" : [NSNumber numberWithBool:YES],
                                                                                                    @"include_player_ids": [NSArray arrayWithArray:_userIdsToConnectWith],
                                                                                                    @"data": @{@"deleteAll":[NSNumber numberWithBool:true]}
                                                                                                    }];

    }
    
}

- (void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
    NSLog(@"Device: %@ deviceDidStartListeningForIncomingConnections", device);
}

- (void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error
{
    NSLog(@"Device: %@ didStopListeningForIncomingConnections: %@", device, error);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)pop:(unsigned) N viewControllersanimated:(BOOL) anim
{
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[self.navigationController viewControllers].count-1-N] animated:anim];
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
