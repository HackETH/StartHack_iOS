//
//  SelectTypeViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "SelectTypeViewController.h"
#import "LanguagePickerTableViewController.h"
#import <Parse/Parse.h>
#import "UserMainViewController.h"


@interface SelectTypeViewController ()

@end

@implementation SelectTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)translatorButton:(id)sender {
    
    
    PFUser *user = [PFUser currentUser];
    user[@"type"] = @"translator";
    [user saveInBackground];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    LanguagePickerTableViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"LanguagePicker"];
    
    
    [add setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    
    [self.navigationController pushViewController:add animated:YES];
    
    
}
- (IBAction)userButton:(id)sender {
    PFUser *user = [PFUser currentUser];
    user[@"type"] = @"user";
    [user saveInBackground];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    UserMainViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"UserMain"];
    
    
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
