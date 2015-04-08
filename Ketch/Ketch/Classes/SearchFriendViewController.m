//
//  SearchFriendViewController.m
//  Ketch
//
//  Created by Andy Bayer on 2/25/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "InviteFriendTableViewController.h"
#import <Parse/Parse.h>

@interface SearchFriendViewController ()

@end

@implementation SearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = .5;
    border.borderColor = [UIColor lightGrayColor].CGColor;
    border.frame = CGRectMake(0, self.searchField.frame.size.height - borderWidth, self.searchField.frame.size.width, self.searchField.frame.size.height);
    border.borderWidth = borderWidth;
    [self.searchField.layer addSublayer:border];
    self.searchField.layer.masksToBounds = YES;
    
    [self.searchField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
        InviteFriendTableViewController *destinationVC = (InviteFriendTableViewController *)[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
        
        [destinationVC loadObjects];
    }
    [super viewWillDisappear:animated];
}

- (IBAction)addPressed:(id)sender {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.searchField.text];
    if (self.searchField.text==[PFUser currentUser].username) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You can't be your own friend" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        
        if (!error) {
            PFRelation *relation = [[PFUser currentUser] objectForKey:@"friend"];
            PFQuery *relationQuery = [relation query];
            [relationQuery whereKey:@"username" equalTo:object[@"username"]];
            NSInteger count = [relationQuery countObjects];
            if (count>0) {
                alert.title = @"Already your friend!";
                [alert show];
                return;
            } else {
                [[PFUser currentUser] addObject:object forKey:@"friend"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        alert.title = @"Friend added";
                        [alert show];
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            }
//            [relationQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//                if (!error) {
//                    if (number>0) {
//                        alert.title = @"Already your friend!";
//                        [alert show];
//                        return;
//                    } else {
//                        [relation addObject:object];
//                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                            if (succeeded) {
//                                alert.title = @"Friend added";
//                                [alert show];
//                            }
//                        }];
//                    }
//                } else {
//                    NSLog(@"count error");
//                }
//            }];
        } else {
            alert.title = @"Friend not found";
            [alert show];
        }
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
