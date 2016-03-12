//
//  AcceptCallViewController.h
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcceptCallViewController : UIViewController

@property (nonatomic, strong) NSString *inviteeIdentity;
@property NSString *conversationId;
@property NSString *twilioId;


@end
