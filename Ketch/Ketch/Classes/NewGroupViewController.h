//
//  NewGroupTableViewController.h
//  Ketch
//
//  Created by Andy Bayer on 5/5/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "GroupAddTableViewController.h"

@interface NewGroupViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, GroupAddTableViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (strong, nonatomic) NSString *groupName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *groupMembers;

@end

