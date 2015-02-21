//
//  NewEventView.m
//  Ping2
//
//  Created by Andy Bayer on 2/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "NewEventView.h"

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
    
    if (self)
    {
        // Initialization code.
        //
        NSLog(@"ayo");
        
        [[NSBundle mainBundle] loadNibNamed:@"NewEventView" owner:self options:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // center views horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.friendView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    
    
}

- (IBAction)segmentPressed:(id)sender {
    long clickedSegment = [sender selectedSegmentIndex];
    
    if (clickedSegment == 0) {
        _minutes = 30;
    } else if (clickedSegment == 1) {
        _minutes = 60;
    } else if (clickedSegment == 2) {
        _minutes = 90;
    } else if (clickedSegment == 3) {
        _minutes = 120;
    }
}


@end
