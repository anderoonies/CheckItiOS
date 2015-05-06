//
//  NewGroupTableViewController.m
//  Ketch
//
//  Created by Andy Bayer on 5/5/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "NewGroupViewController.h"
#import "ContactUtilities.h"
#import "GroupAddTableViewController.h"
#import "InviteFriendTableViewController.h"
#import "CoolBar.h"

@interface NewGroupViewController ()

@property (strong, nonatomic) ContactUtilities *contactUtilities;

@property (strong, nonatomic) CoolBar *coolBar;

@end

@implementation NewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contactUtilities = [[ContactUtilities alloc] init];
    self.tableView.editing = YES;
    
    // init that array
    
    _groupMembers = [[NSMutableArray alloc] init];
    _groupName = [[NSString alloc] init];
    
    _groupNameField.delegate = self;
    
    // load up dat cool bar
    
    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CoolBar" owner:nil options:nil]; // did it load?
    id obj = [arr objectAtIndex: 0];
    CoolBar *toolBar = (CoolBar *) obj;
    toolBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 70);
    
    [toolBar.button setTitle:@"MAKE GROUP" forState:UIControlStateNormal];
    
    [toolBar addTarget:self action:@selector(makeGroup) forControlEvents:UIControlEventTouchUpInside];
    [toolBar.button addTarget:self action:@selector(makeGroup) forControlEvents:UIControlEventTouchUpInside];
    
    self.coolBar = toolBar;
    
    [self.navigationController.view addSubview:self.coolBar];
    
    [self.groupNameField becomeFirstResponder];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    
    if (_groupName) {
        _groupNameField.text = _groupName;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([_groupMembers count]>0 && ([_groupName length]>0)) {
        [self enterButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.groupNameField resignFirstResponder];
    [self exitButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self exitButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark TableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupMembers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *object = [_groupMembers objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
    if (object[@"phone"]) {
        cell.textLabel.text = [_contactUtilities phoneToName:object[@"phone"]];
        if (cell.textLabel.text==nil) {
            cell.textLabel.text=object[@"username"];
        }
    } else {
        cell.textLabel.text = object[@"username"];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark GroupAdd Delegate

- (void)passList:(NSMutableArray *)friendList
{
    _groupMembers = friendList;
}

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
#pragma mark Button

- (void)makeGroup
{
    [_groupMembers addObject:[PFUser currentUser]];
    
    // check if group with same name exists
    
    PFRelation *userGroups = [[PFUser currentUser] relationForKey:@"group"];
    [[userGroups query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *group in objects) {
                if (group[@"name"] == _groupName) {
                    [self groupAlert];
                    return;
                }
            }
        }
    }];
    
    
    // save group
    
    PFObject *group = [PFObject objectWithClassName:@"Group"];
    group[@"name"] = self.groupNameField.text;
    group[@"members"] = _groupMembers;
    group[@"creator"] = [PFUser currentUser];
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"group creation failed, %@", error);
        } else {
            NSInteger myIndex = [self.navigationController.viewControllers indexOfObject:self];
            if ( myIndex != 0 && myIndex != NSNotFound ) {
                [(InviteFriendTableViewController *)[self.navigationController.viewControllers objectAtIndex:myIndex-1] loadObjects];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    // adding group to user is done with cloud code after save

}

#pragma mark -
#pragma mark TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //hide the keyboard
    [textField resignFirstResponder];
    
    //return NO or YES, it doesn't matter
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _groupName = _groupNameField.text;
    
    if ([_groupMembers count]>0) {
        [self enterButton];
    }
}

#pragma mark -
#pragma mark Group Alert

- (void)groupAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A group already exists with this name."
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GroupAddTableViewController *destVC = [segue destinationViewController];
    destVC.delegate = self;
    
}


@end
