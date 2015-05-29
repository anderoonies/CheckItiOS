//
//  AddFriendTableViewController.m
//  Ketch
//
//  Created by Andy Bayer on 2/28/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "AddFriendTableViewController.h"

@implementation AddFriendTableViewController

- (void)viewDidLoad {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mixpanel = [Mixpanel sharedInstance];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [_mixpanel track:@"Username Search Add Pressed" properties:nil];
    } else {
        [_mixpanel track:@"Contacts Add Pressed" properties:nil];
    }
}

@end

