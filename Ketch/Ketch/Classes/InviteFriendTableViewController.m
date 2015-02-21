//
//  TimelineTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/7/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "InviteFriendTableViewController.h"
#import "MapViewController.h"
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>

@interface InviteFriendTableViewController ()

@end

@implementation InviteFriendTableViewController

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

- (void)viewWillAppear:(BOOL)animated {
    // make sure toolbar is hidden when we navigate to the view    
    [self.navigationController setToolbarHidden:YES];
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
        if (friend == nil) {
            return;
        }
        
        NSLog(@"Found %@", friend.username);
        
        PFRelation *relation = [[PFUser currentUser] objectForKey:@"friend"];
        [relation addObject:friend];
        [[PFUser currentUser] saveInBackground];
        
        [self.friendList addObject:friend];
    }
}

#pragma mark -
#pragma mark Selections

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    NSLog(@"%@", object);
   
    if (object[@"phone"]) {
        NSString *friendNumber = object[@"phone"];
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        for(int i = 0; i < numberOfPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                if ([[phoneNumber substringToIndex:1] isEqualToString:@"1"]) {
                    phoneNumber = [@"+" stringByAppendingString:phoneNumber];
                } else if(![[phoneNumber substringToIndex:1] isEqual:@"+"]) {
                    phoneNumber = [@"+1" stringByAppendingString:phoneNumber];
                }
                
                // get rid of all characters for consistency in lookups
                phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()  -."]] componentsJoinedByString:@""];
                
                if ([phoneNumber isEqualToString:friendNumber]) {
                    if (lastName) {
                        cell.textLabel.text = [firstName stringByAppendingString:[@" " stringByAppendingString:lastName]];
                    } else {
                        cell.textLabel.text = firstName;
                    }
                    return cell;
                }
            }
        }
    }
    
    cell.textLabel.text = object[@"username"];

    return cell;
}

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