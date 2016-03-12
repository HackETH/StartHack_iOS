//
//  TranslatorMainViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "TranslatorMainViewController.h"
#import "LanguagePickerTableViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface TranslatorMainViewController ()

@end

@implementation TranslatorMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];

    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] oneSignal]  IdsAvailable:^(NSString* userId, NSString* pushToken) {
        PFUser *user = [PFUser currentUser];
        
        if (![user[@"pushID"] isEqualToString:userId]) {
            user[@"pushID"] = userId;
            [user saveInBackground];
        }
        
        
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editLanguages:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    LanguagePickerTableViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"LanguagePicker"];
    
    
    [add setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navigationController pushViewController:add animated:YES];
    
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
