//
//  AddFriendTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 2/17/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactUtilities.h"
#import "InviteFriendTableViewController.h"
#import <AddressBook/AddressBook.h>

@interface ContactsTableViewController ()

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self loadObjects];
    
    _friendList = [[NSMutableArray alloc] initWithCapacity:[self.objects count]];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
        InviteFriendTableViewController *destinationVC = (InviteFriendTableViewController *)[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
        
        [destinationVC loadObjects];
    }
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark PFQuery methods

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The key of the PFObject to display in the label of the default cell style
        self.parseClassName = @"friend";
        
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
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" containedIn:_friendNumbers];
    if ([friendQuery countObjects]>0) {
        [query whereKey:@"username" doesNotMatchKey:@"username" inQuery:friendQuery];
    }
    
    if ([query countObjects]==0) {
        [self friendAlert];
        return nil;
    } else {
        return query;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    cell.accessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    ContactUtilities *contactUtilities = [[ContactUtilities alloc] init];
    
    NSLog(@"%@", object);
    
    if (object[@"phone"]) {
        cell.textLabel.text = [contactUtilities phoneToName:object[@"phone"]];
        if (cell.textLabel.text==nil) {
            cell.textLabel.text = object[@"username"];
        }
    } else {
        cell.textLabel.text = object[@"username"];
    }
    
    return cell;
}

- (void)objectsDidLoad:(NSError *)error {
    _friendList = [NSMutableArray arrayWithArray:self.objects];
    [super objectsDidLoad:error];
}

//- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
//    return _friendList[indexPath.row];
//}

#pragma mark -
#pragma mark Table View Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.objects count];
}

#pragma mark -
#pragma mark Selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *newFriend = [_friendList objectAtIndex:[indexPath row]];
    
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryView = nil;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:newFriend.objectId block:^(PFObject *object, NSError *error) {
        if (object) {
            [[[PFUser currentUser] relationForKey:@"friend"] addObject:object];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"added");
                } else {
                    NSLog(@"%@", error);
                }
            }];
        } else {
            NSLog(@"%@", error.userInfo);
        }
    }];
}

- (IBAction)addFriendPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Friend Alert

#define ADD_FRIEND 5

- (void)friendAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're already friends with all contacts!"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStyleDefault;
    alert.tag = ADD_FRIEND;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == ADD_FRIEND) {
        [self.navigationController popViewControllerAnimated:YES];
//        PFQuery *query = [PFUser query];
//        [query whereKey:@"username" equalTo:enteredText];
//        
//        PFUser *friend = (PFUser *)[query getFirstObject];
//        if (friend == nil) {
//            return;
//        }
//        
//        NSLog(@"Found %@", friend.username);
//        
//        PFRelation *relation = [[PFUser currentUser] objectForKey:@"friend"];
//        [relation addObject:friend];
//        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                NSLog(@"saved friend");
//            }
//        }];
    }
    
//    [self loadObjects];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    PFQueryTableViewController *destination = (PFQueryTableViewController *)[segue destinationViewController];
//    [destination loadObjects];
//}
//
//-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
//{
//    CATransition* transition = [CATransition animation];
//    transition.duration = .25;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
//    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
//    
//    
//    
//    [self performSegueWithIdentifier:@"returnToInvite" sender:gestureRecognizer];
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
