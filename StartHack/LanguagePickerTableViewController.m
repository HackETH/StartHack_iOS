//
//  LanguagePickerTableViewController.m
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import "LanguagePickerTableViewController.h"
#import "StandardTableViewCell.h"
#import <Parse/Parse.h>
#import "TranslatorMainViewController.h"

@interface LanguagePickerTableViewController ()

@property NSMutableArray *languages;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@end

@implementation LanguagePickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *user = [PFUser currentUser];
    
    if (user[@"languagesData"]) {
        self.languages = user[@"languagesData"];
    }
    else {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"languages" ofType:@"plist"];
        self.languages = [[NSMutableArray alloc]initWithContentsOfFile:path];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
- (IBAction)backButton:(id)sender {
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
       [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextButton:(id)sender {
    PFUser *user = [PFUser currentUser];
    NSMutableArray *userLanguages = [[NSMutableArray alloc] init];
    for (NSDictionary *language in self.languages) {
        if([language[@"selected"] isEqualToString:@"yes"]) {
            [userLanguages addObject:language[@"language_name"]];
        }
    }
    
    if (user[@"languages"]) {
        user[@"languages"] = userLanguages;
        user[@"languagesData"] = self.languages;
        [user saveInBackground];
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
    user[@"languages"] = userLanguages;
    user[@"languagesData"] = self.languages;
    [user saveInBackground];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    TranslatorMainViewController *add = [storyboard instantiateViewControllerWithIdentifier:@"TranslatorMain"];
    
    
    [add setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self.navigationController pushViewController:add animated:YES];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StandardTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier: @"StandardCell" forIndexPath:indexPath];
    
    NSMutableDictionary *language = self.languages[indexPath.row];
    if (language[@"selected"]==nil) {
        [language setObject:@"no" forKey:@"selected"];
        self.languages[indexPath.row] = language;
    }
    
    if ([language[@"selected"] isEqualToString:@"no"]) {
        cell.languageSelectedImage.image = [UIImage imageNamed:@"unchecked"];
        cell.sideColor.backgroundColor = [UIColor whiteColor];
    }
    else {
        cell.languageSelectedImage.image = [UIImage imageNamed:@"checked"];
        cell.sideColor.backgroundColor = UIColorFromRGB(0x05AE00);
    }
    
    cell.englishLanguageLabel.text = language[@"language_name"];
    cell.languageLabel.text = language[@"native_name"];
    
    cell.clipsToBounds = YES;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSMutableDictionary *language = self.languages[indexPath.row];
    
    if ([language[@"selected"] isEqualToString:@"no"]) {
        language[@"selected"] = @"yes";
    }
    else language[@"selected"] = @"no";
    
    self.languages[indexPath.row] = language;
    
    [self.tableView reloadData];


}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
