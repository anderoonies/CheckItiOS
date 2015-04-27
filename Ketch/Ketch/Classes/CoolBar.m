//
//  CoolBar.m
//  Ketch
//
//  Created by Andy Bayer on 4/27/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "CoolBar.h"

@implementation CoolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code.
        [[NSBundle mainBundle] loadNibNamed:@"CoolBar" owner:self options:nil];
    }
        
    return self;
}

- (void)updateButtonText:(NSString *)buttonText {
    _button.titleLabel.text = buttonText;
}

@end
