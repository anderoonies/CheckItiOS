//
//  NewEventView.m
//  Ping2
//
//  Created by Andy Bayer on 2/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "NewEventView.h"
#import <math.h>

@implementation NewEventView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.createButton.enabled = NO;
    self.createButton.alpha = 0.4f;
    
    _minutesArray = [[NSMutableArray alloc] initWithCapacity:12];
    
    for (int i=5; i<=120; i+=5) {
        int j=0;
        [_minutesArray addObject:[NSNumber numberWithInt:i]];
        j+=1;
    }
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    [self.pickerView selectRow:5 inComponent:0 animated:YES];
    
    int cur_minutes = [(NSNumber *)[_minutesArray objectAtIndex:0] intValue];
    self.minutes = cur_minutes;
    
    
    if (self)
    {
        // Initialization code.
        [[NSBundle mainBundle] loadNibNamed:@"NewEventView" owner:self options:nil];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _arrayPos = 6;

    // center views horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.friendView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_minutesArray count];
}


#pragma mark -
#pragma mark UIPickerViewDelegate

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", [_minutesArray objectAtIndex:row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _minutes = (int)[[_minutesArray objectAtIndex:row] integerValue];
}


#pragma mark -
#pragma mark Utilities

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end

