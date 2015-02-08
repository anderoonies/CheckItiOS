//
//  TimelineTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "InviteFriendTableViewController.h"
#import "MapViewController.h"
#import <Parse/Parse.h>

@interface InviteFriendTableViewController ()

@end

@implementation InviteFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // allows user to check multiple friends
    self.tableView.allowsMultipleSelection = YES;
    
    self.sendButton.target = self;
    self.sendButton.action = @selector(sendInvite);
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.friendList = [[NSMutableArray alloc] init];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES];
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

#pragma mark -
#pragma mark Friends

// define a constant to be used as a tag for the UI Alert View
#define ADD_FRIEND 1

- (IBAction)addFriend:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter username"
                                                    message:nil
                                                    delegate:self
                                                    cancelButtonTitle:@"Continue"
                                                    otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = ADD_FRIEND;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Friend's username";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *enteredText = [[alertView textFieldAtIndex:0] text];
    if (alertView.tag == ADD_FRIEND) {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:enteredText];
        PFUser *friend = (PFUser *)[query getFirstObject];
        NSLog(@"Found %@", friend.username);
        
        PFRelation *relation = [[PFUser currentUser] objectForKey:@"friend"];
        [relation addObject:friend];
        [[PFUser currentUser] saveInBackground];
    }
}

#pragma mark -
#pragma mark Selections

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // add the checkmark to the cell
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // if the toolbar for sending the invite is not visibile, set it to visible
    if ([self.navigationController.toolbar isHidden] == YES) {
        [self.navigationController setToolbarHidden:NO];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // remove the checkmark from the cell
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
    // if no more cells are checked, remove the toolbar
    if ([[tableView indexPathsForSelectedRows] count] < 1) {
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)sendInvite {
    for (NSIndexPath *index in [self.tableView indexPathsForSelectedRows]) {
        PFObject *object = [self.objects objectAtIndex:[index row]];
        NSLog(@"%@", object);
        [self.friendList addObject:object];
    }
    
    [self performSegueWithIdentifier:@"returnToMap" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[MapViewController class]]) {
        MapViewController *destVC = [segue destinationViewController];
        destVC.friendList = _friendList;
        
        [destVC updateSubview];
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