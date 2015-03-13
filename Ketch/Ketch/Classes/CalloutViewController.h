//
//  CalloutViewController.h
//  Ping2
//
//  Created by Andy Bayer on 2/8/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "FriendAnnotation.h"
#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface CalloutViewController : UIViewController <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *nameLabelValue;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *timeLabelValue;
@property (strong, nonatomic) IBOutlet UIControl *notifyButton;
@property (strong, nonatomic) IBOutlet UIImageView *notifyImage;
@property (strong, nonatomic) FriendAnnotation *annotation;
@property (strong, nonatomic) UIColor *notifyButtonColor;
@property (strong, nonatomic) MapViewController *mapVC;
@property (nonatomic, assign, getter=isOwn) BOOL own;


- (void)setNameLabel:(UILabel *)nameLabel;
- (void)setTimeLabel:(UILabel *)timeLabel;
- (IBAction)buttonPressed:(id)sender;
- (void)notifyPressed;

@end


@interface CalloutViewController (OwnCalloutViewController)

- (void)cancelPressed;

@end
