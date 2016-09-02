//
//  RateViewController.m
//  StartHack
//
//  Created by Samuel Mueller on 05.08.16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//
#define testing YES
#import "RateViewController.h"
#import <Parse/Parse.h>
@interface RateViewController ()

@end

@implementation RateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_DetailsTextField setHidden:YES];
    [_questionLabel setHidden:YES];
    [_DetailsTextField setDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)callWasHelpfullPressed:(id)sender {
    [self goBack];
}
- (IBAction)callWasNotHelpfulPressed:(id)sender {
    if (_DetailsTextField.hidden == YES) {
        [_DetailsTextField setHidden:NO];
        [_questionLabel setAlpha:0];
        [_questionLabel setHidden:NO];

        [UIView animateWithDuration:1.0 animations:^{
            [_questionLabel setAlpha:1];
            [_wasnthelpfulbutton setBackgroundColor:[self colorWithHexString:@"EFC94C"]];
            [_wasnthelpfulbutton setTitle:NSLocalizedString(@"No connection was established", nil)  forState:UIControlStateNormal];
        }];

        //[_wasnthelpfulbutton setHidden:YES];
        [_DetailsTextField becomeFirstResponder];

    }else{
        [self goBack];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"Return pressed");
        if ([[[textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""]
             
 isEqualToString:@""]) {
            [_writeSomethingLabel setHidden:NO];
        }else{
            if (_userId) {
                [PFCloud callFunctionInBackground:@"reportUser" withParameters:@{@"userId":_userId,@"why":textView.text}];
            }else{
                NSLog(@"No userId of other user available in RateViewController");
            }
            
            [self goBack];
        }

    } else {
        NSLog(@"Other pressed");
    }
    return YES;
}
-(void)goBack
{
    if (!testing) {
        PFUser *user = [PFUser currentUser];
        if ([user[@"type"] isEqualToString:@"translator"]) {
            // Check if the user allready selected languages
            [self pop:4 viewControllersanimated:NO];
        }else{
            [self pop:3 viewControllersanimated:NO];
            
        }
    }else{
        [self pop:1 viewControllersanimated:NO];
    }
    
}
-(void)pop:(unsigned) N viewControllersanimated:(BOOL) anim
{
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:[self.navigationController viewControllers].count-1-N] animated:anim];
}
-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
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
