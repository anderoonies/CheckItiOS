//
//  CalloutViewController.m
//  Ping2
//
//  Created by Andy Bayer on 2/8/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "CalloutViewController.h"
#import <Parse/Parse.h>

@interface CalloutViewController ()

@end

@implementation CalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.nameLabelValue;
    self.timeLabel.text = self.timeLabelValue;
    
//    UIImage *buttonImage = [[UIImage alloc] init];
    UIImageView *buttonImageView = [[UIImageView alloc] initWithFrame:self.notifyButton.frame];
    
    if ([self isOwn]) {
        self.notifyButtonColor = [UIColor redColor];
        
//        buttonImage = [self imageWithImage:[UIImage imageNamed:@"close"] scaledToSize:buttonImageView.frame.size];
    } else {
        self.notifyButtonColor = [UIColor blueColor];

//        self.notifyImage = buttonImageView;
    }
    
    
    [self.notifyButton setBackgroundColor:self.notifyButtonColor];
    self.notifyImage = buttonImageView;
    NSLog(@"%f and %f", self.notifyImage.frame.size.width, self.notifyImage.frame.size.height);
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

- (IBAction)buttonPressed:(id)sender {
    if ([self isOwn]) {
        [self cancelPressed];
    } else {
        [self notifyPressed];
    }
}
- (void)notifyPressed {
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
//    [animation setDuration:0.01];
//    [animation setRepeatCount:8];
//    [animation setAutoreverses:YES];
//    [animation setFromValue:[NSValue valueWithCGPoint:
//                             CGPointMake([_notifyImage center].x - 5.0f, [_notifyImage center].y)]];
//    [animation setToValue:[NSValue valueWithCGPoint:
//                           CGPointMake([_notifyImage center].x + 5.0f, [_notifyImage center].y)]];
//    [[_notifyImage layer] addAnimation:animation forKey:@"position"];
//
//    [_notifyButton setBackgroundColor:[UIColor colorWithRed:(95/255.0) green:(201/255.0) blue:(56/255.0) alpha:1.0]];
//
//    _annotation.didNotify = YES;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                              otherButtonTitles:[NSString stringWithFormat:@"Nudge %@", self.nameLabel.text], nil];
    
    actionSheet.tag = 1;
    [actionSheet showInView:self.mapVC.view];

    _annotation.didNotify = YES;
    
    NSString *notificationMessage = [[NSString alloc] init];
    notificationMessage = [NSString stringWithFormat:@"%@ nudged you!", [PFUser currentUser]];
    
    NSDictionary *data = @{
                           @"alert" : @"Someone nudged you!",
                           @"pn" : [PFUser currentUser][@"phone"] // Photo's object id
                           };
    PFPush *push = [[PFPush alloc] init];
    [push setData:data];
    [push sendPushInBackground];
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

@implementation CalloutViewController (OwnCalloutViewController)

- (void)cancelPressed {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Event"
                                                    otherButtonTitles:nil];
    
    actionSheet.tag = 2;
    [actionSheet showInView:self.mapVC.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"The %@ button was tapped.", [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        [actionSheet removeFromSuperview];
        return;
    } else {
        if (actionSheet.tag == 2) {
            PFQuery *userEvent = [PFQuery queryWithClassName:@"event"];
            [userEvent whereKey:@"user" equalTo:[PFUser currentUser]];
            [userEvent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    for (PFObject *object in objects) {
                        [object delete];
                    }
                }
            }];
            
            [self.mapVC close:self];
            self.mapVC.userMarker.map = nil;
        } else if (actionSheet.tag == 1) {
            [PFCloud callFunctionInBackground:@"push" withParameters:@{@"targetUserId":self.annotation} block:^(id object, NSError *error) {
                if (!error) {
                    NSLog(@"push called");
                } else {
                    NSLog(@"%@", error);
                }
            }];
        }
    }
}


@end
