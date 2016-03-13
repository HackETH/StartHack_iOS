//
//  ViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//


#import <Parse/Parse.h>
#import "ViewController.h"
#import "SelectTypeViewController.h"
#import "LanguagePickerTableViewController.h"
#import "TranslatorMainViewController.h"
#import "UserMainViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *oval1;
@property (weak, nonatomic) IBOutlet UIImageView *oval2;
@property (weak, nonatomic) IBOutlet UIImageView *oval3;
@property (weak, nonatomic) IBOutlet UIImageView *oval4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 3.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    
    [self.oval1.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    rotationAnimation.duration = 3.8;
    [self.oval3.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: - M_PI * 2.0 ];
    rotationAnimation.duration = 3.3;
    [self.oval2.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    rotationAnimation.duration = 3.4;
    [self.oval4.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                      NSFontAttributeName:[UIFont fontWithName:@"Avenir" size:21]}];
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    
    PFUser *user = [PFUser currentUser];
    
    
    // Check if we allready have a user
    if (user) {
        
        // Check if we allready set the user type
        if ([user[@"type"] isEqualToString:@"translator"]) {
            // Check if the user allready selected languages
            if (user[@"languages"]) {
                //Present the Main Translator View
                [[self navigationController] setNavigationBarHidden:YES animated:NO];
                
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                TranslatorMainViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"TranslatorMain"];
                
                
                [self.navigationController pushViewController:add animated:NO];
                
            }
            else {
                //Present the Language Picker View
                [[self navigationController] setNavigationBarHidden:YES animated:NO];
                
                
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                SelectTypeViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"selectType"];
                
                
                [self.navigationController pushViewController:add animated:NO];
            }
            
        }
        else {
            
            if ([user[@"type"] isEqualToString:@"user"]) {
            //Present the Type Selector View (Translator or User)
            [[self navigationController] setNavigationBarHidden:YES animated:NO];
            
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle:nil];
            UserMainViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"UserMain"];
            
            
            [self.navigationController pushViewController:add animated:NO];
            }
            else {
                [[self navigationController] setNavigationBarHidden:YES animated:NO];
                
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                SelectTypeViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"selectType"];
                
                
                [self.navigationController pushViewController:add animated:NO];
            }
        }
        
        
    }
    
    else {
        
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
                [[self navigationController] setNavigationBarHidden:YES animated:NO];
                
                
                UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle:nil];
                SelectTypeViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"selectType"];
                
                
                [self.navigationController pushViewController:add animated:NO];
            }
        }];
        
    }
    
    
    
    
    
    
    [super viewDidAppear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
