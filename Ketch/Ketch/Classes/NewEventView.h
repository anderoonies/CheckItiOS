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

@interface NewEventView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIControl *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
//@property (strong, nonatomic) V8HorizontalPickerView *timePickerView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *friendListLabel;
@property (strong, nonatomic) NSMutableArray *minutesArray;
@property (nonatomic, assign) NSInteger arrayPos;
@property (nonatomic, assign) int minutes;
@property (assign) CGFloat shift;
@property (assign) BOOL increasing;
@property (assign, nonatomic) BOOL hidden;

@end
