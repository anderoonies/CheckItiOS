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
#import <MessageUI/MessageUI.h>

@interface ContactsTableViewController () <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *friendsInApp;
@property (strong, nonatomic) NSMutableArray *friendsInAppNumbers;
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) ContactUtilities *contactUtilities;
@property (strong, nonatomic) NSIndexPath *activePath;

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _friendNumbers = [[NSMutableArray alloc] init];
    _contacts = [[NSMutableArray alloc] init];
    _friendsInApp = [[NSMutableArray alloc] init];
    _friendsInAppNumbers = [[NSMutableArray alloc] init];
    _contactUtilities = [[ContactUtilities alloc] init];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                _friendNumbers = [_contactUtilities getCleanNumbers];
                _contacts = [_contactUtilities getContacts];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                NSLog(@"contacts denied");
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        _friendNumbers = [_contactUtilities getCleanNumbers];
        _contacts = [_contactUtilities getContacts];
    }
    
    _friendList = [[NSMutableArray alloc] initWithCapacity:[self.contacts count]];
    
    PFQuery *friendQuery = [PFUser query];
    PFRelation *friendRelation = [[PFUser currentUser] relationForKey:@"friend"];
    [friendQuery whereKey:@"phone" containedIn:_friendNumbers];
    [friendQuery whereKey:@"username" doesNotMatchKey:@"username" inQuery:[friendRelation query]];
    
    _friendsInApp = [[NSMutableArray alloc] initWithArray:[friendQuery findObjects]];
    for (PFObject *object in _friendsInApp) {
        [_friendsInAppNumbers addObject:object[@"phone"]];
    }
    
    
//    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            _friendsInApp = [[NSMutableArray alloc] initWithArray:objects];
//            for (PFObject *object in objects) {
//                [_friendsInAppNumbers addObject:object[@"phone"]];
//            }
//            [self.tableView reloadData];
//        } else {
//            _friendsInApp = nil;
//        }
//    }];
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"friendCell"];
    }
    
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [accessoryButton addTarget:self action:@selector(addFriendPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = accessoryButton;
    
    ABRecordRef person = (__bridge ABRecordRef)([_contacts objectAtIndex:indexPath.row]);
    
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);

    cell.textLabel.text = [NSString stringWithFormat:@"%@%@", firstName ? [NSString stringWithFormat:@"%@ ", firstName] : @"", lastName ?: @""];;
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        phone = [_contactUtilities cleanNumber:phone];
        if ([_friendsInAppNumbers containsObject:phone]) {
            cell.detailTextLabel.text = nil;
            return cell;
        };
    }
    
    cell.detailTextLabel.text = @"Invite to use the app!";
    
    return cell;
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
    return [_contacts count];
}

#pragma mark -
#pragma mark Selections
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ABRecordRef person = (__bridge ABRecordRef)([_contacts objectAtIndex:indexPath.row]);
    
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);

    NSMutableArray *phoneStrings = [[NSMutableArray alloc] init];
    
    // check if the person is in the app by comparing phone numbers. if so, query to add and return.
    
    for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        phone = [_contactUtilities cleanNumber:phone];
        [phoneStrings addObject:phone];
    }
    
    for (NSString *phoneNumber in phoneStrings) {
        if ([_friendsInAppNumbers containsObject:phoneNumber]) {
            PFQuery *query = [PFUser query];
            [query whereKey:@"phone" equalTo:phoneNumber];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if ([objects count]==1) {
                        PFObject *object = objects[0];
                        [[[PFUser currentUser] relationForKey:@"friend"] addObject:object];
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"added");
                                [self.tableView cellForRowAtIndexPath:indexPath].accessoryView = nil;
                                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                                [PFCloud callFunctionInBackground:@"friendAddNotify" withParameters:@{@"targetId": object.objectId, @"username": [PFUser currentUser].username}];
                            } else {
                                NSLog(@"%@", error);
                            }
                        }];
                    }
                }
            }];
            return;
        }
    }
    
    // this occurs otherwise—when we need to move to the SMS invite page.
    _activePath = indexPath;
    [self showSMS:phoneStrings[0]];
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

- (void)restoreCell:(NSIndexPath *)indexPath
{
    UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [accessoryButton targetForAction:@selector(addFriendPressed:) withSender:self];
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryView = accessoryButton;
}

- (void)sentInvite:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.detailTextLabel.text = @"Invite sent!";
}

#pragma mark -
#pragma mark MFMessageDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            [self restoreCell:_activePath];
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            [self sentInvite:_activePath];
            break;
            
        default:
            [self restoreCell:_activePath];
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(NSString *)number {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[number];
    NSString *message = [NSString stringWithFormat:@"Hey! Add me on Ketch, my username is %@. ketch.strikingly.com", [PFUser currentUser][@"username"]];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
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
