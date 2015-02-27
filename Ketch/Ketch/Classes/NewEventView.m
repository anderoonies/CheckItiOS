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
        
        [[NSBundle mainBundle] loadNibNamed:@"NewEventView" owner:self options:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _minutesArray = [[NSMutableArray alloc] initWithCapacity:12];
    
    for (int i=0; i<=120; i+=5) {
        int j=0;
        [_minutesArray addObject:[NSNumber numberWithInt:i]];
        j+=1;
    }
    
    _arrayPos = 6;
    
    for (int i=0; i<5; i++) {
        self.timeLabel.text = [self.timeLabel.text stringByAppendingString:[NSString stringWithFormat:@"%@ ", [_minutesArray objectAtIndex:i]]];
    };
    
    // center views horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.friendView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTimeWithGestureRecognizer:)];
    [self.timeView addGestureRecognizer:panGestureRecognizer];
    
    
}

-(void)updateTimeWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    NSLog(@"%f", [panGestureRecognizer translationInView:self.timeView].x);
    NSInteger shift = [panGestureRecognizer translationInView:self.timeView].x;
    NSInteger shiftIncrement = shift % 10;
    if (shiftIncrement < 0) {
        [self timeShift:shiftIncrement];
    } else if (shiftIncrement > 0) {
        [self timeShift:shiftIncrement];
    }
}

- (void)timeShift:(NSInteger)increment {
    
}

//- (IBAction)segmentPressed:(id)sender {
//    long clickedSegment = [sender selectedSegmentIndex];
//    
//    if (clickedSegment == 0) {
//        _minutes = 30;
//    } else if (clickedSegment == 1) {
//        _minutes = 60;
//    } else if (clickedSegment == 2) {
//        _minutes = 90;
//    } else if (clickedSegment == 3) {
//        _minutes = 120;
//    }
//}


@end
