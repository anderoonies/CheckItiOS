//
//  NewUserViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/26/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "NewUserViewController.h"
#import <Parse/Parse.h>

@interface NewUserViewController ()

@end

@implementation NewUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    self.phoneField.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self.usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Sign Up

- (IBAction)newUserPressed:(id)sender {
    [self processFieldEntries];
}

- (void)processFieldEntries {
    // Check that we have a non-zero username and passwords.
    // Compare password and passwordAgain for equality
    // Throw up a dialog that tells them what they did wrong if they did it wrong.
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    NSString *passwordAgain = self.passwordAgainField.text;
    NSString *phoneNumber = [@"+1" stringByAppendingString:[[self.phoneField.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"() -"]] componentsJoinedByString:@""]];
    NSString *errorText = @"Please ";
    NSString *usernameBlankText = @"enter a username";
    NSString *passwordBlankText = @"enter a password";
    NSString *joinText = @", and ";
    NSString *passwordMismatchText = @"enter the same password twice";
    NSString *phoneShortText = @"enter a 10 digit phone number";
    
    BOOL textError = NO;
    
    // Messaging nil will return 0, so these checks implicitly check for nil text.
    if (username.length == 0 || password.length == 0 || passwordAgain.length == 0 || phoneNumber.length == 0) {
        textError = YES;
        
        // Set up the keyboard for the first field missing input:
        if (passwordAgain.length == 0) {
            [self.passwordAgainField becomeFirstResponder];
        }
        if (password.length == 0) {
            [self.passwordField becomeFirstResponder];
        }
        if (username.length == 0) {
            [self.usernameField becomeFirstResponder];
        }
        if (phoneNumber.length ==0) {
            [self.phoneField becomeFirstResponder];
        }
        
        if (username.length == 0) {
            errorText = [errorText stringByAppendingString:usernameBlankText];
        }
        
        if (password.length == 0 || passwordAgain.length == 0) {
            if (username.length == 0) { // We need some joining text in the error:
                errorText = [errorText stringByAppendingString:joinText];
            }
            errorText = [errorText stringByAppendingString:passwordBlankText];
        }
        
        if (phoneNumber.length < 10) {
            errorText = [errorText stringByAppendingString:phoneShortText];
        }
    } else if ([password compare:passwordAgain] != NSOrderedSame) {
        // We have non-zero strings.
        // Check for equal password strings.
        textError = YES;
        errorText = [errorText stringByAppendingString:passwordMismatchText];
        [self.passwordField becomeFirstResponder];
    }
    
    if (textError) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorText message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        return;
    }
    
    // Call into an object somewhere that has code for setting up a user.
    // The app delegate cares about this, but so do a lot of other objects.
    // For now, do this inline.
    
    PFQuery *phoneQuery = [PFUser query];
    [phoneQuery whereKey:@"phone" equalTo:phoneNumber];
    [phoneQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        if ([objects count]>0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User already exists with that number"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Close", nil];
            [alertView show];

            [self.phoneField becomeFirstResponder];
            return;
        } else {
            PFUser *user = [PFUser user];
            user.username = username;
            user.password = password;
            user[@"phone"] = phoneNumber;
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"]
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"Close", nil];
                    [alertView show];
                    // Bring the keyboard back up, because they'll probably need to change something.
                    [self.usernameField becomeFirstResponder];
                    return;
                }
                
                // Success!
                NSLog(@"good");
                PFUser *user = [PFUser currentUser];
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:user forKey: @"owner"];
                [currentInstallation saveInBackground];
                [user saveInBackground];
                [self performSegueWithIdentifier:@"returnToMap" sender:self];        
                //        [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
    
    if (length == 0 || (length > 10 && !hasLeadingOne) || (length > 11)) {
        textField.text = decimalString;
        return NO;
    }
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (hasLeadingOne) {
        [formattedString appendString:@"1 "];
        index += 1;
    }
    
    if (length - index > 3) {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ",areaCode];
        index += 3;
    }
    
    if (length - index > 3) {
        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-",prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    
    return NO;
}

#pragma mark -
#pragma mark Navigation

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismissed");
    }];
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
