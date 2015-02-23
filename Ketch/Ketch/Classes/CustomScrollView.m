//
//  CustomScrollView.m
//  Ketch
//
//  Created by Andy Bayer on 2/23/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "CustomScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    NSObject * transparent = (NSObject *) [[UIColor colorWithWhite:0 alpha:0] CGColor];
    NSObject * opaque = (NSObject *) [[UIColor colorWithWhite:0 alpha:1] CGColor];
    
    CAGradientLayer* hMaskLayer = [CAGradientLayer layer];
    hMaskLayer.opacity = .7;
    hMaskLayer.colors = [NSArray arrayWithObjects:transparent, opaque, opaque, transparent, nil];
    hMaskLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                            [NSNumber numberWithFloat:0.2],
                            [NSNumber numberWithFloat:0.8],
                            [NSNumber numberWithFloat:1.0], nil];
    hMaskLayer.startPoint = CGPointMake(0, 0.5);
    hMaskLayer.endPoint = CGPointMake(1.0, 0.5);
    hMaskLayer.bounds = self.bounds;
    hMaskLayer.anchorPoint = CGPointZero;
    
    // Set the frame
    
    self.layer.mask = hMaskLayer;
    
    [CATransaction commit];
}

@end
