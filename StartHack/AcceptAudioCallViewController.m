//
//  AcceptAudioCallViewController.m
//  StartHack
//
//  Created by Samuel Mueller on 21.07.16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "AcceptAudioCallViewController.h"
#import "CallViewController.h"
#import <Parse/Parse.h>

@interface AcceptAudioCallViewController ()

@end

@implementation AcceptAudioCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *urlString = [NSString stringWithFormat:@"https://helpingvoice.herokuapp.com/token?client=%@", [PFUser currentUser].objectId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error = nil;
    _token = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

}
- (IBAction)takeCallPressed:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    CallViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"Call"];
    add.token = _token;
    add.needsHelp = false;
    add.reachHere = self.reachHere;
    [self presentViewController:add animated:NO completion:^{
        
    }];
}
- (IBAction)declineCallPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
