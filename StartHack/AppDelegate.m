//
//  AppDelegate.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AcceptCallViewController.h"
#import "ConversationViewController.h"
#import <TwilioConversationsClient/TwilioConversationsClient.h>


@interface AppDelegate () 




@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"1sYvxjSWZhqp1hBSfzLTftPau1rBD6B07VrGEqWQ"
                  clientKey:@"K2lY94TC18AMim1erOQcaryGTAHBEGoVHJ4iCKPF"];
    
    self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions
                                                        appId:@"65875f80-874f-4502-8c5e-9a22ce8dab4f"
                                           handleNotification:^(NSString* message, NSDictionary* additionalData, BOOL isActive) {
                                               NSLog(@"OneSignal Notification opened:\nMessage: %@", message);
                                               
                                               if (additionalData) {
                                                   NSLog(@"additionalData: %@", additionalData);
                                                   
                                                   
                                                   
                                                   
                                                           
                                                           UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                                                                bundle:nil];
                                                           AcceptCallViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"AcceptCall"];
                                                           
                                                           
                                                           
                                                           
                                                           add.inviteeIdentity =additionalData[@"twilioId"];
                                                           
                                                           
                                                           
                                                           
                                                           
                                                           
                                                           [(UINavigationController *)self.window.rootViewController pushViewController:add animated:NO];
                                                     
                                                   
                                                   
                                                   
                                                   
                                                   // Check for and read any custom values you added to the notification
                                                   // This done with the "Additonal Data" section the dashbaord.
                                                   // OR setting the 'data' field on our REST API.
                                                   NSString* customKey = additionalData[@"customKey"];
                                                   if (customKey)
                                                       NSLog(@"customKey: %@", customKey);
                                               }
                                           }];
    
    [self.oneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        NSLog(@"UserId:%@", userId);
        if (pushToken != nil)
            NSLog(@"pushToken:%@", pushToken);
    }];
    
    return YES;
}





- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
