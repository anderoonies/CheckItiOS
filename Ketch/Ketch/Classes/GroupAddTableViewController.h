//
//  GroupAddTableViewController.h
//  Ketch
//
//  Created by Andy Bayer on 5/6/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@protocol GroupAddTableViewControllerDelegate <NSObject>
@required
- (void)passList:(NSMutableArray *)friendList;

@end

@interface GroupAddTableViewController : PFQueryTableViewController

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *friendIndexList;
@property (strong, nonatomic) id<GroupAddTableViewControllerDelegate> delegate;

@end
