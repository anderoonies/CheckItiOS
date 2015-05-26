//
//  AboutViewController.m
//  Ketch
//
//  Created by Andy Bayer on 5/26/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
    }];
}

@end
