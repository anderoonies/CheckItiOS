//
//  OwnCalloutViewController.m
//  Ketch
//
//  Created by Andy Bayer on 3/9/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "OwnCalloutViewController.h"
#import "MapViewController.h"

@interface OwnCalloutViewController ()

@end

@implementation OwnCalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.nameLabelValue;
    self.timeLabel.text = self.timeLabelValue;
    self.notifyButtonColor = [UIColor redColor];
    [self.notifyButton setBackgroundColor:self.notifyButtonColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)notifyPressed:(id)sender {
    
    PFQuery *userEvent = [PFQuery queryWithClassName:@"event"];
    [userEvent whereKey:@"user" equalTo:[PFUser currentUser]];
    [userEvent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object delete];
            }
        }
    }];
    
    self.mapVC.userMarker.map = nil;
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
