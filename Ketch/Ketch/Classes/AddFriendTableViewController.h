//
//  AddFriendTableViewController.h
//  Ketch
//
//  Created by Andy Bayer on 2/28/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mixpanel.h"

@interface AddFriendTableViewController : UITableViewController

@property (strong, nonatomic) Mixpanel *mixpanel;

@end
