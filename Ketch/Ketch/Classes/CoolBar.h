//
//  CoolBar.h
//  Ketch
//
//  Created by Andy Bayer on 4/27/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoolBar : UIControl
@property (strong, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) NSString* buttonText;

@end
