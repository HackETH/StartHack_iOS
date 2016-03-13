//
//  StandardTableViewCell.h
//  StartHack
//
//  Created by Peter Müller on 12/03/16.
//  Copyright © 2016 Müller & Müller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *englishLanguageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *languageSelectedImage;
@property (weak, nonatomic) IBOutlet UILabel *sideColor;

@end
