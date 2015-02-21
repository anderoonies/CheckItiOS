//
//  SettingsViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/30/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@property (nonatomic,strong) UISwipeGestureRecognizer *swipeLeftGestureRecognizer;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Navigation

- (void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom



    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];

}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    UIViewController *destinationVC = [sender destinationViewController];
//    destinationVC.navigationController.navigationBarHidden = NO;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
