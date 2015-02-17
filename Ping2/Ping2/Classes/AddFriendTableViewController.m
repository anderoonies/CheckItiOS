//
//  AddFriendTableViewController.m
//  Ping2
//
//  Created by Andy Bayer on 2/17/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "AddFriendTableViewController.h"
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
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self checkContacts];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
                NSLog(@"contacts denied");
            }
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self checkContacts];
    }
    
    PFRelation *friendRelation = [[PFUser currentUser] objectForKey:@"friend"];
    PFQuery *friendQuery = [friendRelation query];
    
//    NSMutableArray *friendIDs = [[NSMutableArray alloc] init];
//    
//    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (objects) {
//            for (PFObject *object in objects) {
//                NSLog(@"%@", object.objectId);
//                [friendIDs addObject:object.objectId];
//            }
//        } else {
//            NSLog(@"%@", error.userInfo);
//        }
//    }];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"phone" containedIn:_friendNumbers];
    [query whereKey:@"friend" doesNotMatchKey:[PFUser currentUser][@"objectID"] inQuery:query];
    return query;
}

- (void)checkContacts
{
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSLog(@"%ld", numberOfPeople);
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSLog(@"Name:%@ %@", firstName, lastName);
        
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
            
            [_friendNumbers addObject:phoneNumber];
        }
        
        NSLog(@"=============================================");
    }
}

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
        
        cell.textLabel.text = object[@"username"];
    }
    
    return cell;
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

- (IBAction)addFriendPressed:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    UITableViewCell* cell = (UITableViewCell*)button.superview.superview;
    UITableView* view = (UITableView*) cell.superview;
    NSIndexPath* indexPath = [view indexPathForCell:cell];
    
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
