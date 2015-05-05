//
//  TimelineTableViewController.h
//  Ping2
//
//  Created by Andy Bayer on 1/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface InviteFriendTableViewController : PFQueryTableViewController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *groupList;
@property (strong, nonatomic) NSMutableArray *friendIndexList;
@property (strong, nonatomic) NSMutableArray *groupIndexList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

-(void)passLists:(NSMutableArray*)friendList groupList:(NSMutableArray*)groupList;

@end
