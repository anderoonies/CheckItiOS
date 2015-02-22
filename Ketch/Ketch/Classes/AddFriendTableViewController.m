//
//  AddFriendTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 2/17/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "AddFriendTableViewController.h"
#import "ContactUtilities.h"
#import <AddressBook/AddressBook.h>

@interface AddFriendTableViewController ()

@end

@implementation AddFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
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
    _friendNumbers = [[NSMutableArray alloc] init];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    ContactUtilities *contactUtilities = [[ContactUtilities alloc] init];
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                _friendNumbers = [contactUtilities getCleanNumbers];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                NSLog(@"contacts denied");
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        _friendNumbers = [contactUtilities getCleanNumbers];
    }

    PFRelation *friendRelation = [[PFUser currentUser] objectForKey:@"friend"];
    PFQuery *friendQuery = [friendRelation query];
    friendQuery.limit = 1000;
    
    if ([friendQuery countObjects]==0) {
        [self friendAlert];
        return friendQuery;
    } else {
        PFQuery *query = [PFUser query];
        [query whereKey:@"phone" containedIn:_friendNumbers];
        [query whereKey:@"username" doesNotMatchKey:@"username" inQuery:friendQuery];
        return query;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    ContactUtilities *contactUtilities = [[ContactUtilities alloc] init];
    
    NSLog(@"%@", object);
    
    if (object[@"phone"]) {
        cell.textLabel.text = [contactUtilities phoneToName:object[@"phone"]];
    } else {
        cell.textLabel.text = object[@"username"];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Selections
- (IBAction)addFriendPressed:(id)sender {
    [(UIButton *)sender setHidden:YES];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFUser *newFriend = [self.objects objectAtIndex:[indexPath row]];
    
    PFRelation *relation = [[PFUser currentUser] objectForKey:@"friend"];

    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:newFriend.objectId block:^(PFObject *object, NSError *error) {
        if (object) {
            NSLog(@"successfully added");
            [relation addObject:object];
        } else {
            NSLog(@"%@", error.userInfo);
        }
    }];
    
    [[PFUser currentUser] saveInBackground];
    [self loadObjects];
}

#pragma mark -
#pragma mark Friend Alert

#define ADD_FRIEND 5

- (void)friendAlert {
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
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"saved friend");
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    PFQueryTableViewController *destination = [sender destinationViewController];
    [destination loadObjects];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
