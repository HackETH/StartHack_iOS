//
//  CallViewController.h
//  StartHack
//
//  Created by Samuel Mueller on 21.07.16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwilioSDK/TwilioClient.h>

@interface CallViewController : UIViewController <TCDeviceDelegate, TCConnectionDelegate>
@property () NSString *firstLanguage;
@property () NSString *secondLanguage;
@property () NSString *token;
@property () NSString *reachHere;
@property () bool needsHelp;
@end
