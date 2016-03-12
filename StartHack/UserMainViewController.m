//
//  UserMainViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "UserMainViewController.h"
#import "UserSelectLanguageTableViewController.h"
#import "SearchingViewController.h"
#import <Parse/Parse.h>


@interface UserMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *makeCallButton;
@property (weak, nonatomic) IBOutlet UILabel *firstLanguageLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLanguageLabel;




@end

@implementation UserMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    PFUser *user = [PFUser currentUser];
    
    self.firstLanguage = user[@"firstLanguage"];
    self.secondLanguage = user[@"secondLanguage"];
    
    if (self.firstLanguage) {
        self.firstLanguageLabel.text = self.firstLanguage;
    }
    if (self.secondLanguage) {
        self.secondLanguageLabel.text = self.secondLanguage;
    }
    
    if (self.firstLanguage && self.secondLanguage) self.makeCallButton.enabled = true;
    else self.makeCallButton.enabled = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectFirstLanguage:(id)sender {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    UserSelectLanguageTableViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"UserSelectLanguage"];
    add.isFirst = true;
    
    
    [self.navigationController pushViewController:add animated:YES];
    
}
- (IBAction)selectSecondLanguage:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    UserSelectLanguageTableViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"UserSelectLanguage"];
    add.isFirst = false;
    
    
    [self.navigationController pushViewController:add animated:YES];
}
- (IBAction)makeCall:(id)sender {
    
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    SearchingViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"Searching"];
    add.firstLanguage = self.firstLanguage;
    add.secondLanguage = self.secondLanguage;
    
    
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
