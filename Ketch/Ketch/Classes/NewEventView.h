//
//  NewEventView.h
//  Ping2
//
//  Created by Andy Bayer on 2/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "GradientView.h"
#import "V8HorizontalPickerView.h"
#import <UIKit/UIKit.h>

@interface NewEventView : UIView <V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) V8HorizontalPickerView *timePickerView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *friendListLabel;
@property (strong, nonatomic) NSMutableArray *minutesArray;
@property (assign) int arrayPos;
@property (assign) NSInteger minutes;
@property (assign) CGFloat shift;
@property (assign) BOOL increasing;
@property (assign, nonatomic) BOOL hidden;

@end
