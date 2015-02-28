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
    
    // resize subviews
    self.buttonView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height/3);
    self.timeView.frame = CGRectMake(self.frame.origin.x, self.buttonView.frame.origin.y + self.buttonView.frame.size.height, self.frame.size.width, self.frame.size.height/3);
    self.friendView.frame = CGRectMake(self.frame.origin.x, self.timeView.frame.origin.y + self.timeView.frame.size.height, self.frame.size.width, self.frame.size.height/3);
    
    _minutesArray = [[NSMutableArray alloc] initWithCapacity:23];
    
    for (int i=5; i<=120; i+=5) {
        int j=0;
        [_minutesArray addObject:[NSNumber numberWithInt:i]];
        j+=1;
    }
    
    self.timePickerView = [[V8HorizontalPickerView alloc] initWithFrame:CGRectMake(0, self.timeView.frame.origin.y, self.frame.size.width, self.frame.size.height/3)];
    self.timePickerView.backgroundColor = [UIColor whiteColor];
    self.timePickerView.selectedTextColor = [UIColor darkGrayColor];
    self.timePickerView.textColor = [UIColor lightGrayColor];
    self.timePickerView.delegate = self;
    self.timePickerView.dataSource = self;
    self.timePickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
    self.timePickerView.selectionPoint = CGPointMake(self.timePickerView.frame.size.width/2, 0);
    self.timePickerView.selectionIndicatorView = [[UIImageView alloc] initWithImage:[self imageWithImage:[UIImage imageNamed:@"chevron1.png"] scaledToSize:CGSizeMake(20, 10)]];
    
    [self addSubview:self.timePickerView];
    
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
    
    _timePickerView.frame = self.timeView.frame;
    
    // center views horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.friendView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

#pragma mark -
#pragma mark V8PickerViewDelegate

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return [_minutesArray count];
};


#pragma mark - 
#pragma mark V8PickerViewDataSource

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%@", [_minutesArray objectAtIndex:index]];
};

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    NSString *text = [NSString stringWithFormat:@"%@", [_minutesArray objectAtIndex:index]];
    CGRect textRect = [text boundingRectWithSize:constrainedSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                         context:nil];
    CGSize textSize = textRect.size;
    return textSize.width + 40.0f; // 20px padding on each side
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

