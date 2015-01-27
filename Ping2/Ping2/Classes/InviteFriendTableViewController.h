//
//  TimelineTableViewController.h
//  Ping2
//
//  Created by Andy Bayer on 1/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteFriendTableViewController : UITableViewController

@property (strong, nonatomic)NSMutableArray *friendList;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFriendButton;

@end
