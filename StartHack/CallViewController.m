//
//  CallViewController.m
//  StartHack
//
//  Created by Samuel Mueller on 21.07.16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "CallViewController.h"
#import <Parse/Parse.h>
#import <OneSignal/OneSignal.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SelectTypeViewController.h"
#import "TranslatorMainViewController.h"
#import "ViewController.h"
#import "TranslatorMainViewController.h"
@interface CallViewController ()
@property (nonatomic) TCDevice *phone;
@property () TCConnection *connection;
@property () bool alwaysReject;
@end

@implementation CallViewController 



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(void)makeCall{
    
    NSDictionary *params = @{@"To": [NSString stringWithFormat:@"client:%@",self.reachHere]};
    
    _connection = [_phone connect:params delegate:self];

}
-(void)connectionDidDisconnect:(TCConnection *)connection
{
    if (!_alwaysReject) {
        [self goBack];
    }
}
-(void)sendRequests{
    PFObject *conversation = [PFObject objectWithClassName:@"Conversations"];
    conversation[@"user"] = [PFUser currentUser];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"languages" containsAllObjectsInArray:@[self.firstLanguage, self.secondLanguage]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                    NSDictionary *data = @{@"conversationId" : conversation.objectId,@"reachMeHere":  [PFUser currentUser].objectId};
                    if (object[@"pushID"]) {
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
    
    [_connection disconnect];
    self.alwaysReject = YES;
    [self goBack];
}
- (void) goBack{
    PFUser *user = [PFUser currentUser];
    if ([user[@"type"] isEqualToString:@"translator"]) {
        // Check if the user allready selected languages
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];


    }else{
        [self.navigationController popViewControllerAnimated:YES];

    }
    
}
- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    NSLog(@"Incoming connection from: %@", [connection parameters][@"From"]);
    if (device.state == TCDeviceStateBusy || !self.needsHelp || self.alwaysReject) {
        [connection reject];
    } else {
        [connection accept];
        _connection = connection;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
