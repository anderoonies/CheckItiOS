//
//  SearchFriendViewController.m
//  Ketch
//
//  Created by Andy Bayer on 2/25/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "SearchFriendViewController.h"
#import <Parse/Parse.h>

@interface SearchFriendViewController ()

@end

@implementation SearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addPressed:(id)sender {
    
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
