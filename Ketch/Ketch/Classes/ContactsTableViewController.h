//
//  AddFriendTableViewController.h
//  Ping2
//
//  Created by Andy Bayer on 2/17/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface ContactsTableViewController : UITableViewController <UITableViewDataSource, UITabBarDelegate>
@property (nonatomic, strong) NSMutableArray *friendNumbers;
@property (nonatomic, strong) NSMutableArray *friendList;

@end
