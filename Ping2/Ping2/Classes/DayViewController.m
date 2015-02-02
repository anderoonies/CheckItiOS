//
//  DayViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/28/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "DayViewController.h"
#import "MAEvent.h"
#import "DetailViewController.h"
#import <Parse/Parse.h>

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface DayViewController ()

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer;

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer;

@end

@implementation DayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* The default is not to autoscroll, so let's override the default here */
    self.dayView.autoScrollToFirstEvent = YES;
    
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToRightWithGestureRecognizer:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event {
    [self performSegueWithIdentifier:@"ShowDetailsSegue" sender:self];
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
    NSString *eventInfo = [NSString stringWithFormat:@"Hour %i. Userinfo: %@", [components hour], [event.userInfo objectForKey:@"test"]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
                                                    message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (MAEvent *)event {
    static int counter;
    static BOOL flag;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[NSString stringWithFormat:@"number %i", counter++] forKey:@"test"];
    
    unsigned int r = arc4random() % 24;
    int rr = arc4random() % 3;
    
    MAEvent *event = [[MAEvent alloc] init];
    event.backgroundColor = [UIColor blueColor];
    event.textColor = [UIColor whiteColor];
    event.allDay = NO;
    event.userInfo = dict;
    
    if (rr == 0) {
        event.title = @"Event lorem ipsum es dolor test. This a long text, which should clip the event view bounds.";
    } else if (rr == 1) {
        event.title = @"Foobar.";
    } else {
        event.title = @"Dolor test.";
    }
    
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:[NSDate date]];
    [components setHour:r];
    [components setMinute:0];
    [components setSecond:0];
    
    event.start = [CURRENT_CALENDAR dateFromComponents:components];
    
    [components setHour:r+rr];
    [components setMinute:0];
    
    event.end = [CURRENT_CALENDAR dateFromComponents:components];
    
    return event;
}

- (NSArray *)dayView:(MADayView *)dayView eventsForDate:(NSDate *)startDate {
    NSDate *date = startDate;
    
    NSArray *arr = [NSArray arrayWithObjects: self.event, self.event, self.event,
                    self.event, self.event, self.event, self.event,  self.event, self.event, nil];

    return arr;
}

- (NSDate *)getToday {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                     fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    
    return today;
}

- (NSArray *)getEvents {
    NSMutableArray *events = [[NSMutableArray alloc] init];
    NSDate *today = [NSDate date];
    PFUser *user = [PFUser currentUser];
    
    if (!user) {
        [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
        ;
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"event"];
        [query whereKey:@"start" greaterThan:today];
        [query whereKey:@"canSee" equalTo:user];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d scores.", objects.count);
                // Do something with the found objects
                [events addObjectsFromArray:objects];
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    return events;
    
//    events = [NSMutableArray arrayWithObjects: self.event, self.event, self.event,
//                    self.event, self.event, self.event, self.event,  self.event, self.event, nil];
//
//    return events;
}

#pragma mark -
#pragma mark Navigation

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
}

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    [self performSegueWithIdentifier:@"AddEventSegue" sender:self];

    
}

- (IBAction)settingsPressed:(id)sender {
    [self performSegueWithIdentifier:@"SettingsSegue" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ShowDetailsSegue"]){
        DetailViewController *detailVC = (DetailViewController *)segue.destinationViewController;
        detailVC.title = self.title;
    }
}

- (IBAction)returnToMap:(UIStoryboardSegue *)segue {
    self.navigationController.navigationBar.hidden=NO;
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
