//
//  DayViewController.m
//  Ping2
//
//  Created by Andy Bayer on 1/28/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "DayViewController.h"
#import "MAEvent.h"

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface DayViewController ()

@end

@implementation DayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* The default is not to autoscroll, so let's override the default here */
    self.dayView.autoScrollToFirstEvent = YES;
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Implementation for the MADayViewDelegate protocol */

- (void)dayView:(MADayView *)dayView eventTapped:(MAEvent *)event {
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
    event.backgroundColor = ((flag = !flag) ? [UIColor purpleColor] : [UIColor brownColor]);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
