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
#import "CallViewController.h"
#import <sys/utsname.h>

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}
@interface UserMainViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstSecondLanguageDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hiDescriptionDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionFirstLanguageDistance;
@property (weak, nonatomic) IBOutlet UIButton *makeCallButton;
@property (weak, nonatomic) IBOutlet UIButton *firstLanguageButton;
@property (weak, nonatomic) IBOutlet UIButton *secondLanguageButton;

@property (nonatomic) NSString *token;



@end

@implementation UserMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([deviceName() isEqualToString:@"iPhone4,1" ]) {
        _hiDescriptionDistance.constant = 8;
        _descriptionFirstLanguageDistance.constant = 8;
        _firstSecondLanguageDistance.constant = 8;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    PFUser *user = [PFUser currentUser];
    NSString *urlString = [NSString stringWithFormat:@"https://helpingvoice.herokuapp.com/token?client=%@", user.objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error = nil;
    _token = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (_token == nil) {
        NSLog(@"Error retrieving token: %@", [error localizedDescription]);
    }

    
    
    self.firstLanguage = user[@"firstLanguage"];
    self.secondLanguage = user[@"secondLanguage"];
    
    if (self.firstLanguage) {
        [_firstLanguageButton setTitle:self.firstLanguage forState:UIControlStateNormal];
        
    }
    if (self.secondLanguage) {
        [_secondLanguageButton setTitle:self.secondLanguage forState:UIControlStateNormal];
        
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
    CallViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"Call"];
    add.firstLanguage = self.firstLanguage;
    add.secondLanguage = self.secondLanguage;
    add.token = _token;
    add.needsHelp = true;
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
