//
//  GroupAddTableViewController.m
//  Ketch
//
//  Created by Andy Bayer on 5/6/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "GroupAddTableViewController.h"
#import "ContactUtilities.h"
#import "CoolBar.h"
#import "NewGroupViewController.h"
#import "Mixpanel.h"

@interface GroupAddTableViewController ()

@property (strong, nonatomic) ContactUtilities *contactUtilities;

@property (strong, nonatomic) CoolBar *coolBar;

@property (strong, nonatomic) Mixpanel *mixpanel;


@end

@implementation GroupAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _mixpanel = [Mixpanel sharedInstance];
    
    _contactUtilities = [[ContactUtilities alloc] init];
    
    _friendList = [[NSMutableArray alloc] init];
    
    NSArray* arr = [[NSBundle mainBundle] loadNibNamed:@"CoolBar" owner:nil options:nil]; // did it load?
    id obj = [arr objectAtIndex: 0];
    CoolBar *toolBar = (CoolBar *) obj;
    toolBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 70);
    
    [toolBar.button setTitle:@"SELECT FRIENDS" forState:UIControlStateNormal];
    
    [toolBar addTarget:self action:@selector(sendInvite) forControlEvents:UIControlEventTouchUpInside];
    [toolBar.button addTarget:self action:@selector(sendInvite) forControlEvents:UIControlEventTouchUpInside];
    
    self.coolBar = toolBar;
    
    [self.navigationController.view addSubview:self.coolBar];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = @"friend";
        self.textKey = @"username";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (PFQuery *)queryForTable
{
    PFRelation *relation = [[PFUser currentUser] objectForKey:self.parseClassName];
    PFQuery *query = [relation query];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell"];
    
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
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_mixpanel track:@"Group Table View Row Selected" properties:@{
                                                                   @"Row": [self.objects objectAtIndex:indexPath.row]
                                                                   }];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // add the checkmark to the cell
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    [self enterButton];
    NSNumber *index = [NSNumber numberWithInt:indexPath.row];
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if ([self.friendList indexOfObject:object]==NSNotFound) {
        [self.friendList addObject:object];
    }
    if ([self.friendIndexList indexOfObject:index]==NSNotFound) {
        [self.friendIndexList addObject:index];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // remove the checkmark from the cell
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
    [_friendList removeObject:[self.objects objectAtIndex:indexPath.row]];
    [_friendIndexList removeObjectIdenticalTo:[NSNumber numberWithInt:indexPath.row]];
    
    // if no more cells are checked, remove the toolbar
    if ([_friendList count] < 1) {
        [self exitButton];
    }
}

#pragma mark -
#pragma mark Coolbar

- (void)sendInvite {
//    [_mixpanel track:@"Group Bar Invite Pressed" properties:nil];
    
    [self.delegate passList:_friendList];
    [self exitButton];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    NewGroupViewController *destVC = (NewGroupViewController *)[segue destinationViewController];
//    [destVC.tableView reloadData];
//}


@end
