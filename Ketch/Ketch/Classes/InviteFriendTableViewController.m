//
//  TimelineTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "InviteFriendTableViewController.h"
#import "MapViewController.h"
#import "ContactUtilities.h"
#import "ContactsTableViewController.h"
#import "AddFriendTableViewController.h"
#import <AddressBook/AddressBook.h>
#import "CoolBar.h"
#import "UIView+FLKAutoLayout.h"
#import <Parse/Parse.h>

@interface InviteFriendTableViewController ()

@property (strong, nonatomic) ContactUtilities *contactUtilities;

@property (strong, nonatomic) CoolBar *coolBar;
@property (strong, nonatomic) NSMutableArray *friendIndexes;
@property (strong, nonatomic) NSMutableArray *groupIndexes;

@end

@implementation InviteFriendTableViewController

#define FRIEND_SEGMENT_INDEX 0
#define GROUP_SEGMENT_INDEX 1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                NSLog(@"contacts granted");
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                NSLog(@"contacts denied");
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        NSLog(@"contacts granted");
    }
    
    _contactUtilities = [[ContactUtilities alloc] init];

    // allows user to check multiple friends
    self.tableView.allowsMultipleSelection = YES;
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (!self.friendList) {
        self.friendList = [[NSMutableArray alloc] init];
    }
    
    if (!self.groupList) {
        self.groupList = [[NSMutableArray alloc] init];
    }
    
    if (!self.friendIndexList) {
        self.friendIndexList = [[NSMutableArray alloc] init];
    }
    
    if (!self.groupIndexList) {
        self.groupIndexList = [[NSMutableArray alloc] init];
    }
    
    
    
    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CoolBar" owner:nil options:nil]; // did it load?
    id obj = [arr objectAtIndex: 0];
    CoolBar *toolBar = (CoolBar *) obj;
    toolBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 70);
    
    [toolBar.button setTitle:@"INVITE FRIENDS" forState:UIControlStateNormal];
    
    [toolBar addTarget:self action:@selector(sendInvite) forControlEvents:UIControlEventTouchUpInside];
    [toolBar.button addTarget:self action:@selector(sendInvite) forControlEvents:UIControlEventTouchUpInside];
    
    self.coolBar = toolBar;
    
    [self.navigationController.view addSubview:self.coolBar];
    
    [self.segmentControl addTarget:self action:@selector(selectorChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated {
    // make sure toolbar is hidden when we navigate to the view    
    [self.navigationController.view addSubview:self.coolBar];
    
    // unless we have enough friends
    if ([[self.tableView indexPathsForSelectedRows] count]) {
        if ([self.navigationController.toolbar isHidden] == YES) {
            [self.navigationController setToolbarHidden:NO];
        }
    }
}

//- (void)viewDidAppear:(BOOL)animated {
////    rewrite this using the indexes we just got
//    for (int section = 0; section < [self.tableView numberOfSections]; section++) {
//        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++) {
//            if ([_friendList indexOfObject:[self.objects objectAtIndex:row]]!=NSNotFound) {
//                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
//                [self tableView:self.tableView didSelectRowAtIndexPath:path];
//                [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
//                UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:path];
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                cell.selected = YES;
//            }
//        }
//    }
//}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
        MapViewController *destinationVC = (MapViewController *)[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 1];
        
        destinationVC.friendList=_friendList;
        [destinationVC updateSubview];
    }
    
    [self exitButton];
    
    [[self.navigationController.view viewWithTag:99] removeFromSuperview];

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PFQuery methods

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"friend";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"username";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
    }
    return self;
}

- (PFQuery *)queryForTable
{
    PFRelation *relation = [[PFUser currentUser] objectForKey:self.parseClassName];
    PFQuery *query = [relation query];
    
    return query;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 4) {
        if (buttonIndex==alertView.cancelButtonIndex) {
            [alertView removeFromSuperview];
        } else {
            AddFriendTableViewController *vc = [[AddFriendTableViewController alloc] init];
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFriendsTableViewController"];
            
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }

}

#pragma mark -
#pragma mark Segment Methods

- (void)loadGroups {
    self.parseClassName = @"group";
    
    self.textKey = @"name";
    
    [self loadObjects];
}


- (void)loadFriends {
    self.parseClassName = @"friend";
    
    self.textKey = @"username";
    
    [self loadObjects];
}


#pragma mark -
#pragma mark Selections

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    if (self.segmentControl.selectedSegmentIndex==FRIEND_SEGMENT_INDEX) {
        if (object[@"phone"]) {
            cell.textLabel.text = [_contactUtilities phoneToName:object[@"phone"]];
            if (cell.textLabel.text==nil) {
                cell.textLabel.text=object[@"username"];
            }
        } else {
            cell.textLabel.text = object[@"username"];
        }
        
        if ([_friendIndexList containsObject:[NSNumber numberWithInt:indexPath.row]]) {
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selected = YES;
        } else {
            [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selected = NO;
        }
    } else if (self.segmentControl.selectedSegmentIndex==GROUP_SEGMENT_INDEX) {
        cell.textLabel.text = object[@"name"];
        
        if ([_groupIndexList containsObject:[NSNumber numberWithInt:indexPath.row]]) {
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selected = YES;
        } else {
            [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selected = NO;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // add the checkmark to the cell
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // if the toolbar for sending the invite is not visibile, set it to visible
    [self enterButton];
    NSNumber *index = [NSNumber numberWithInt:indexPath.row];

    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if (self.segmentControl.selectedSegmentIndex==FRIEND_SEGMENT_INDEX) {
        if ([self.friendList indexOfObject:object]==NSNotFound) {
            [self.friendList addObject:object];
        }
        if ([self.friendIndexList indexOfObject:index]==NSNotFound) {
            [self.friendIndexList addObject:index];
        }
    } else if (self.segmentControl.selectedSegmentIndex==GROUP_SEGMENT_INDEX) {
        if ([self.groupList indexOfObject:object]==NSNotFound) {
            [self.groupList addObject:object];
        }
        if ([self.groupIndexList indexOfObject:index]==NSNotFound) {
            [self.groupIndexList addObject:index];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // remove the checkmark from the cell
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
    if (self.segmentControl.selectedSegmentIndex==FRIEND_SEGMENT_INDEX) {
        [_friendList removeObject:[self.objects objectAtIndex:indexPath.row]];
        [_friendIndexList removeObjectIdenticalTo:[NSNumber numberWithInt:indexPath.row]];
    }
    else if (self.segmentControl.selectedSegmentIndex==GROUP_SEGMENT_INDEX) {
        [_groupList removeObject:[self.objects objectAtIndex:indexPath.row]];
        [_groupIndexList removeObjectIdenticalTo:[NSNumber numberWithInt:indexPath.row]];
    }
    
    // if no more cells are checked, remove the toolbar
    if (([_friendIndexList count] + [_groupIndexList count]) < 1) {
        [self exitButton];
    }
}

- (void)sendInvite {
    [self.delegate passLists:_friendList groupList:_groupList];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[MapViewController class]]) {
        MapViewController *destVC = [segue destinationViewController];
        destVC.friendList = _friendList;
        destVC.eventCreateSubview.friendList = _friendList;
        [destVC updateSubview];
    } else if ([[segue sourceViewController] isKindOfClass:[ContactsTableViewController class]]) {
        NSLog(@"coming in");
    }
}

- (IBAction)addPressed:(id)sender
{
    if (self.segmentControl.selectedSegmentIndex == FRIEND_SEGMENT_INDEX) {
        [self performSegueWithIdentifier:@"AddFriendSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"CreateGroupSegue" sender:self];
    }
}

- (IBAction)returnToInvite:(UIStoryboardSegue *)segue {
    self.navigationController.navigationBar.hidden=NO;
}

//- (void)passLists:(NSMutableArray *)friendList groupList:(NSMutableArray *)groupList {
//    _friendList = friendList;
//    _groupList = groupList;
//}

#pragma mark -
#pragma mark Animation

- (void)enterButton {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.coolBar.frame = CGRectMake(0,
                                                         self.view.frame.size.height-70.0f,
                                                         self.view.frame.size.width,
                                                         70.0f);
                     }
                     completion:^(BOOL finished) {
                         self.coolBar.button.enabled = YES;
                     }
     ];
}

- (void)exitButton {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.coolBar.frame = CGRectMake(0,
                                                         self.view.frame.size.height,
                                                         self.view.frame.size.width,
                                                         70.0f);
                     }
                     completion:^(BOOL finished) {
                         self.coolBar.button.enabled = NO;
                     }
     ];
}

#pragma mark - 
#pragma mark Selector

- (IBAction)selectorChanged:(id)sender {
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            [self loadFriends];
            break;
        case 1:
            [self loadGroups];
            break;
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





@end