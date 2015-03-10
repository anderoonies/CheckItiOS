//
//  OwnCalloutViewController.h
//  Ketch
//
//  Created by Andy Bayer on 3/9/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "MapViewController.h"
#import "CalloutViewController.h"
#import <Parse/Parse.h>

@interface OwnCalloutViewController : CalloutViewController

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *nameLabelValue;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *timeLabelValue;
@property (strong, nonatomic) FriendAnnotation *annotation;
@property (strong, nonatomic) UIColor *notifyButtonColor;
@property (strong, nonatomic) MapViewController *mapVC;

@property (weak, nonatomic) IBOutlet UIImageView *closeImage;
@property (weak, nonatomic) IBOutlet UIControl *closeButton;

- (void)setNameLabel:(UILabel *)nameLabel;
- (void)setTimeLabel:(UILabel *)timeLabel;

@end
