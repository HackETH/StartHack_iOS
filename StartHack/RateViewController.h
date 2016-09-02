//
//  RateViewController.h
//  StartHack
//
//  Created by Samuel Mueller on 05.08.16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *wasHelpfulButton;
@property (weak, nonatomic) IBOutlet UIButton *wasnthelpfulbutton;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *DetailsTextField;
@property (weak, nonatomic) IBOutlet UILabel *writeSomethingLabel;
@property () NSString *userId;
@end
