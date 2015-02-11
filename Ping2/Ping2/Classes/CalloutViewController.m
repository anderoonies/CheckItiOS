//
//  CalloutViewController.m
//  Ping2
//
//  Created by Andy Bayer on 2/8/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "CalloutViewController.h"

@interface CalloutViewController ()

@end

@implementation CalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.nameLabelValue;
    self.timeLabel.text = self.timeLabelValue;
    if (self.notifyButtonColor == nil) {
        self.notifyButtonColor = [UIColor blueColor];
    }
    [self.notifyButton setBackgroundColor:self.notifyButtonColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNameLabel:(UILabel *)nameLabel {
    _nameLabel = nameLabel;
}

- (void)setTimeLabel:(UILabel *)timeLabel {
    _timeLabel = timeLabel;
}

- (IBAction)notifyPressed:(id)sender {
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.01];
    [animation setRepeatCount:8];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([_notifyImage center].x - 5.0f, [_notifyImage center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([_notifyImage center].x + 5.0f, [_notifyImage center].y)]];
    [[_notifyImage layer] addAnimation:animation forKey:@"position"];
    
    [_notifyButton setBackgroundColor:[UIColor colorWithRed:(95/255.0) green:(201/255.0) blue:(56/255.0) alpha:1.0]];
    
    _annotation.didNotify = YES;
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
