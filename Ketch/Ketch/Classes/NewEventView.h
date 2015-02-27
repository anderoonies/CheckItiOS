//
//  NewEventView.h
//  Ping2
//
//  Created by Andy Bayer on 2/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "GradientView.h"
#import <UIKit/UIKit.h>

@interface NewEventView : UIView
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *friendListLabel;
@property (strong, nonatomic) NSMutableArray *minutesArray;
@property (assign) int arrayPos;
@property (assign) int minutes;
@property (assign, nonatomic) BOOL hidden;

@end
