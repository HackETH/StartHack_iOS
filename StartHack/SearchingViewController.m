//
//  SearchingViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "SearchingViewController.h"
#import <Parse/Parse.h>
#import <TwilioSDK/TwilioClient.h>
#import "AppDelegate.h"
#import "ConversationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchingViewController () <TCDeviceDelegate,UIAlertViewDelegate>

@property NSString *identity;

@property (nonatomic) TwilioConversationsClient *conversationsClient;
@property (nonatomic) TWCIncomingInvite *incomingInvite;

@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIImageView *oval3;
@property (weak, nonatomic) IBOutlet UIImageView *oval4;
@property (weak, nonatomic) IBOutlet UILabel *searchingLable;
@property (strong,nonatomic) TCDevice *phone;
@property (strong,nonatomic) TCConnection *connection;
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
-(void)viewDidAppear:(BOOL)animated{
    PFUser *user = [PFUser currentUser];
    NSString *urlString = [NSString stringWithFormat:@"https://helpingvoice.herokuapp.com/token?client=%@",user.objectId ];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error = nil;
    NSString *token = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (token == nil) {
        NSLog(@"Error retrieving token: %@", [error localizedDescription]);
    } else {
        _phone = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
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
                            NSDictionary *data = @{@"conversationId" : conversation.objectId,@"reachMeHere":  user.objectId};
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
    }
}
- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection
{
    NSLog(@"Incoming connection from: %@", [connection parameters][@"From"]);
    if (device.state == TCDeviceStateBusy) {
        [connection reject];
    } else {
        [connection accept];
        _connection = connection;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
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
