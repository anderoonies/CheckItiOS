//
//  TimelineTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "InviteFriendTableViewController.h"
#import <Parse/Parse.h>

@interface InviteFriendTableViewController ()

@property (strong, nonatomic)NSMutableArray *friendList;

@end

@implementation InviteFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // allows user to check multiple friends
    self.tableView.allowsMultipleSelection = YES;
    
    self.sendButton.target = self;
    self.sendButton.action = @selector(sendInvite);
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self getFriends];

    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSLog(@"%d", [_friendList count]);
    return [self.friendList count];
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
        
        NSLog(@"%@", [PFUser currentUser].username);
    }
}


- (void) getFriends {
    NSMutableArray *friendList = [[NSMutableArray alloc] init];
    PFRelation *relation = [[PFUser currentUser] objectForKey:@"friend"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d friends.", friends.count);
            [friendList addObjectsFromArray:friendList];
            // Do something with the found objects
            for (PFObject *friend in friends) {
                [self addFriendToList:friend];
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) addFriendToList:(PFObject *)friend {
//    NSLog(@"%@", friend[@"username"]);
    [self.friendList addObject:friend[@"username"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"friendCell"];
        cell.selectionStyle = UITableViewCellAccessoryCheckmark;
    }
    
    cell.textLabel.text = _friendList[[indexPath row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // add the checkmark to the cell
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
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
        NSLog(@"%@", [self.tableView cellForRowAtIndexPath:index].textLabel.text);
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end