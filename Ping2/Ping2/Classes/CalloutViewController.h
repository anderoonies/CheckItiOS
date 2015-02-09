//
//  CalloutViewController.h
//  Ping2
//
//  Created by Andy Bayer on 2/8/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalloutViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *nameLabelValue;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *timeLabelValue;
@property (strong, nonatomic) IBOutlet UIControl *notifyButton;
@property (weak, nonatomic) IBOutlet UIImageView *notifyImage;


- (void)setNameLabel:(UILabel *)nameLabel;
- (void)setTimeLabel:(UILabel *)timeLabel;

@end
