//
//  NewEventView.h
//  Ping2
//
//  Created by Andy Bayer on 2/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "CustomScrollView.h"
#import <UIKit/UIKit.h>

@interface NewEventView : UIView
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet CustomScrollView *timeScrollView;
@property (weak, nonatomic) IBOutlet UIView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *friendListLabel;
@property (assign, nonatomic) NSInteger minutes;
@property (assign, nonatomic) BOOL hidden;

@end
