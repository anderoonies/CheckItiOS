
//
//  MapViewController.m
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import "MapViewController.h"
#import "FriendAnnotation.h"
#import "UserAnnotation.h"
#import "DetailViewController.h"
#import "FriendAnnotationView.h"
#import "CustomGMSMarker.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface MapViewController () <GMSMapViewDelegate, WYPopoverControllerDelegate>

@property (nonatomic, strong) NSMutableArray *mapMarkers;
@property (nonatomic, strong) UIPopoverController *bridgePopoverController;
@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UserAnnotation *userAnnotation;
@property (nonatomic, strong) CustomGMSMarker *userMarker;
@property (nonatomic, strong) NewEventView *eventCreateSubview;

@end


#pragma mark -

@implementation MapViewController

- (void)gotoDefaultLocation
{
    // pad our map by 10% around the farthest annotations
#define MAP_PADDING 1.1
    
    // we'll make sure that our minimum vertical span is about a kilometer
    // there are ~111km to a degree of latitude. regionThatFits will take care of
    // longitude, which is more complicated, anyway.
#define MINIMUM_VISIBLE_LATITUDE 0.01
    
    CGFloat minLatitude = 42.056861, maxLatitude = 42.056861, minLongitude = -87.679650, maxLongitude = -87.679650;
    for (FriendAnnotation *friend in _mapMarkers) {
        minLatitude = MIN(minLatitude, friend.coordinate.latitude);
        maxLatitude = MAX(maxLatitude, friend.coordinate.latitude);
        minLongitude = MIN(minLongitude, friend.coordinate.longitude);
        maxLongitude = MAX(maxLongitude, friend.coordinate.longitude);
    }
    
    CGFloat lat= (minLatitude + maxLatitude) / 2;
    CGFloat lon = (minLongitude + maxLongitude) / 2;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat
                                                            longitude:lon
                                                                 zoom:17];
    
    mapView_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateAnnotations];
    [self gotoDefaultLocation];
    
    mapView_.delegate = self;
    
    self.view = mapView_;
    
    [mapView_ animateToViewingAngle:60];

    self.eventCreateSubview = [[[NSBundle mainBundle] loadNibNamed:@"NewEventView" owner:self options:nil] objectAtIndex:0];
    
    self.eventCreateSubview.buttonView.frame = CGRectMake(CGRectGetMinX(self.eventCreateSubview.frame),
                                               CGRectGetMinY(self.eventCreateSubview.frame),
                                               CGRectGetWidth(self.eventCreateSubview.frame),
                                               CGRectGetHeight(self.eventCreateSubview.frame) / [[self.eventCreateSubview subviews] count]);
    
    self.eventCreateSubview.timeView.frame = CGRectMake(CGRectGetMinX(self.eventCreateSubview.frame),
                                             CGRectGetMaxY(self.eventCreateSubview.buttonView.frame),
                                             CGRectGetWidth(self.eventCreateSubview.frame),
                                             CGRectGetHeight(self.eventCreateSubview.frame) / [[self.eventCreateSubview subviews] count]);
    
    self.eventCreateSubview.friendView.frame = CGRectMake(CGRectGetMinX(self.eventCreateSubview.frame),
                                               CGRectGetMaxY(self.eventCreateSubview.timeView.frame),
                                               CGRectGetWidth(self.eventCreateSubview.frame),
                                               CGRectGetHeight(self.eventCreateSubview.frame) / [[self.eventCreateSubview subviews] count]);
    
    
    for (UIView *view in [self.eventCreateSubview subviews]) {
        CALayer *bottomBorder = [CALayer layer];
    
        bottomBorder.frame = CGRectMake(0.0f, CGRectGetMaxY(view.frame), CGRectGetWidth(view.frame), 1.0f);
        
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                         alpha:1.0f].CGColor;
        
        [view.layer addSublayer:bottomBorder];
    }
    
//    // add gesture recognizer
//    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
//    self.longPressGestureRecognizer.minimumPressDuration = 1.0f;
//    self.longPressGestureRecognizer.allowableMovement = 100.0f;
//    
//    [self.view addGestureRecognizer:self.longPressGestureRecognizer];

    
    // initialize locationmanager
    self.locationManager = [[CLLocationManager alloc] init];
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // start getting user's location
    [self.locationManager startUpdatingLocation];
    
    mapView_.myLocationEnabled = YES;


    // create out annotations array (in this example only 2 for testing)
    self.mapMarkers = [[NSMutableArray alloc] initWithCapacity:2];
    
    [self generateAnnotations];
    
    // remove any annotations that exist
    [mapView_ clear];
    
    // add both annotations
    for (FriendAnnotation *annotation in _mapMarkers) {
        CustomGMSMarker *marker = [CustomGMSMarker markerWithPosition:annotation.coordinate];
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [self makeAnnotationImage:annotation];
        marker.title = [annotation getInitials];
        marker.snippet = [annotation getTimeLabel];
        marker.annotation = annotation;
        marker.map = mapView_;
    }
}

- (void)generateAnnotations {
#define THIRTY_MINUTES_IN_SECONDS 1800
    
    NSDate *curDate = [NSDate date];
    
    NSDateComponents *time = [[NSCalendar currentCalendar]
                              components:NSCalendarUnitHour | NSCalendarUnitMinute
                              fromDate:curDate];
    NSInteger minutes = [time minute];
    float minuteUnit = ceil((float) minutes / 15.0);
    minutes = minuteUnit * 5.0;
    [time setMinute: minutes];
    curDate = [[NSCalendar currentCalendar] dateFromComponents:time];

    FriendAnnotation *friend1 = [[FriendAnnotation alloc] init];
    friend1.name = @"James Ross";
    friend1.startTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS sinceDate:curDate];
    friend1.endTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS sinceDate:friend1.startTime];
    friend1.coordinate = CLLocationCoordinate2DMake(42.055969, -87.673255);
    
    
    FriendAnnotation *friend2 = [[FriendAnnotation alloc] init];
    friend2.name = @"Lindsay Weir";
    friend2.startTime = curDate;
    friend2.endTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS * 2 sinceDate:friend2.startTime];
    friend2.coordinate = CLLocationCoordinate2DMake(42.053213, -87.672268);
    
    FriendAnnotation *friend3 = [[FriendAnnotation alloc] init];
    friend3.name = @"Rust Hale";
    friend3.startTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS * 2 sinceDate:curDate];
    friend3.endTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS * 3 sinceDate:friend3.startTime];
    friend3.coordinate = CLLocationCoordinate2DMake(42.057833, -87.676388);
    
    
    FriendAnnotation *friend4 = [[FriendAnnotation alloc] init];
    friend4.name = @"Will Levi";
    friend4.startTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS * 2 sinceDate:curDate];
    friend4.endTime = [NSDate dateWithTimeInterval:THIRTY_MINUTES_IN_SECONDS * 3 sinceDate:friend4.startTime];
    friend4.coordinate = CLLocationCoordinate2DMake(42.054025, -87.676388);
    
    [self.mapMarkers addObject:friend1];
    [self.mapMarkers addObject:friend2];
    [self.mapMarkers addObject:friend3];
    [self.mapMarkers addObject:friend4];
}

#pragma mark - GMSMapViewDelegate

-(BOOL) mapView:(GMSMapView *) mapView didTapMarker:(CustomGMSMarker *)marker
{
    if (popoverController == nil) {
        [self showPopover:marker];
    } else {
        [self close:nil];
    }
    return YES;
}

//- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)view
//{
//    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
//        return;
//    }
//    
//    _recentSender = view;
//    if (popoverController == nil) {
//        [self showPopover:view];
//    } else {
//        [self close:nil];
//    }
//}

#pragma mark -
#pragma mark Utilities

- (UIImage *)makeAnnotationImage:(FriendAnnotation *)annotation
{
    float scale=[[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect whiteCircle = CGRectMake(0, 0, 30, 30);
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetAlpha(ctx, 1.0f);
    CGContextFillEllipseInRect(ctx, whiteCircle);
    
    CGRect greenCircle = CGRectMake(CGRectGetMinX(whiteCircle) + 2.5f, // compensate for difference in size
                                    CGRectGetMinY(whiteCircle) + 2.5f,
                                    25,
                                    25);
    
    if ([annotation isKindOfClass:[UserAnnotation class]]) {
        CGContextSetFillColorWithColor(ctx, [[UIColor blueColor] CGColor]);
    } else {
        CGContextSetFillColorWithColor(ctx, [[UIColor greenColor] CGColor]);
    }
    
    CGContextSetAlpha(ctx, .7f);
    CGContextFillEllipseInRect(ctx, greenCircle);
    
    if (![annotation isKindOfClass:[UserAnnotation class]]) {
        UILabel *initials = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(greenCircle), CGRectGetMinY(greenCircle), CGRectGetWidth(greenCircle) - 5, CGRectGetHeight(greenCircle) -5)];
        initials.text = [annotation getInitials];
        [initials setFont:[UIFont systemFontOfSize:12]];
        initials.textColor = [UIColor grayColor];
        initials.minimumScaleFactor = 0;
        initials.textAlignment = NSTextAlignmentCenter;
        [initials sizeToFit];
        
        [initials drawTextInRect:greenCircle];
    }
    
    UIImage *resultingCircle = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(ctx);

    return resultingCircle;
}

#pragma mark -
#pragma mark Popovers

- (IBAction)showPopover:(id)sender
{
    if (popoverController == nil)
    {
        CustomGMSMarker *senderMarker = [[CustomGMSMarker alloc] init];
        senderMarker = (CustomGMSMarker *) sender;
        FriendAnnotation *annotation = senderMarker.annotation;
        
        CalloutViewController *calloutVC = [[CalloutViewController alloc] init];
        calloutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CalloutViewController"];
        
        calloutVC.preferredContentSize = CGSizeMake(200, 50);
        calloutVC.annotation = annotation;
        calloutVC.nameLabelValue = annotation.name;
        calloutVC.timeLabelValue = [annotation getTimeLabel];
        
        if (annotation.didNotify) {
            calloutVC.notifyButtonColor = [UIColor colorWithRed:(95/255.0) green:(201/255.0) blue:(56/255.0) alpha:1.0];
        }
        
        popoverController = [[WYPopoverController alloc] initWithContentViewController: calloutVC];
        
        popoverController.delegate = self;
        
        CGPoint annotation_point = [mapView_.projection pointForCoordinate:senderMarker.position];
        
        [popoverController presentPopoverFromRect:CGRectMake(annotation_point.x - senderMarker.icon.size.width / 2, annotation_point.y - senderMarker.icon.size.height, senderMarker.icon.size.width, senderMarker.icon.size.height) inView:mapView_ permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES options:WYPopoverAnimationOptionFadeWithScale];
    } else {
        [self close:nil];
//        [self mapView:mapView didDeselectAnnotationView:sender];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    popoverController.delegate = nil;
    popoverController = nil;
    
//    NSArray *selectedAnnotations = mapView.selectedAnnotations;
//    for (MKAnnotationView *annotationView in selectedAnnotations) {
//        [mapView deselectAnnotation:(id)annotationView animated:YES];
//    }
}

- (void)close:(id)sender
{
    [popoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:popoverController];
    }];
    
}

#pragma mark -
#pragma mark Gestures

//- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
//{
//    if ([sender isEqual:self.longPressGestureRecognizer]) {
//        if (sender.state == UIGestureRecognizerStateBegan)
//        {
//            CGPoint touchLocation = [sender locationInView:mapView];
//            
//            CLLocationCoordinate2D coordinate;
//            coordinate = [mapView convertPoint:touchLocation toCoordinateFromView:mapView];// how to convert this to a String or something else?
//            
//            UserAnnotation *newUserAnnotation = [[UserAnnotation alloc] init];
//            newUserAnnotation.name = @"Me";
//            newUserAnnotation.coordinate = coordinate;
//            
//            [mapView removeAnnotation:_userAnnotation];
//            
//            _userAnnotation = newUserAnnotation;
//            [mapView addAnnotation:newUserAnnotation];
//            
//            mapView.centerCoordinate = coordinate;
//            
//            [self showSubview];
//        }
//    }
//}

- (IBAction)addEventButtonPress:(id)sender
{
    CGPoint point = mapView_.center;
    CLLocationCoordinate2D center = [mapView_.projection coordinateForPoint:point];
    
    UserAnnotation *newUserAnnotation = [[UserAnnotation alloc] init];
    newUserAnnotation.name = @"Me";
    newUserAnnotation.coordinate = center;
    
    _userAnnotation = newUserAnnotation;
    
    _userMarker.map = nil;
    
    _userMarker.position = _userAnnotation.coordinate;
    
    [self showSubview];
    
}

#pragma mark -
#pragma mark New Event Subview

- (void)showSubview {
    [self.view addSubview:self.eventCreateSubview];
    
    self.eventCreateSubview.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.eventCreateSubview.frame.size.height);
    [UIView animateWithDuration:.75
                     animations:^{
                         self.eventCreateSubview.frame = CGRectMake(0,
                                                         self.view.frame.size.height - self.eventCreateSubview.frame.size.height,
                                                         self.view.frame.size.width,
                                                         self.eventCreateSubview.frame.size.height);
                     }
     ];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%f", [self.view viewWithTag:1].frame.origin.y);
    UITouch *aTouch = [touches anyObject];
    if (aTouch.tapCount == 1)
    {
        CGPoint p = [aTouch locationInView:self.view];
        for (UIView *aView in [self.view subviews]) {
            if (([aView isKindOfClass:[NewEventView class]])&&(!CGRectContainsPoint(aView.frame, p)))
            {
                _userMarker.map = nil;
                [self hideSubview];
            }
        }
    }
}

- (void)hideSubview {
    [UIView animateWithDuration:.75
                     animations:^{
                         self.eventCreateSubview.frame = CGRectMake(0,
                                                         self.view.frame.size.height,
                                                         self.view.frame.size.width,
                                                         self.eventCreateSubview.frame.size.height);
                     }
                     completion:^(BOOL finished){ [self.eventCreateSubview removeFromSuperview]; }
     ];
}

- (void)updateSubview {
    NSMutableArray *friendStrings = [[NSMutableArray alloc] init];
    for (PFObject *object in _friendList) {
        [friendStrings addObject:object[@"username"]];
    }
    
    self.eventCreateSubview.friendListLabel.text = [friendStrings componentsJoinedByString:@", "];
}

- (IBAction)createEventPressed:(id)sender {
    if (!_friendList) {
        return;
    }
    
    PFObject *event = [PFObject objectWithClassName:@"event"];
    NSDate *curDate = [NSDate date];
    event[@"user"] = [PFUser currentUser];
    event[@"startTime"] = curDate;
    event[@"endTime"] = [NSDate dateWithTimeInterval:self.eventCreateSubview.minutes * 60 sinceDate:curDate];
    event[@"canSee"] = _friendList;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:_userAnnotation.coordinate.latitude longitude:_userAnnotation.coordinate.longitude];
    event[@"location"] = point;

    [self hideSubview];
    
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved object");
        } else {
            NSLog(@"%@", error);
        }
    }];
    
}

- (IBAction)segmentPressed:(id)sender {
    
}

#pragma mark -
#pragma mark Buttons

- (IBAction)settingsPressed:(id)sender {
    [self performSegueWithIdentifier:@"SettingsSegue" sender:sender];
//    PFUser *currentUser = [PFUser currentUser];
//    if (currentUser) {
//        [self performSegueWithIdentifier:@"SettingsSegue" sender:sender];
//    } else {
//        [self performSegueWithIdentifier:@"LoginSegue" sender:sender];
//    }
}

- (IBAction)pushAddLocation:(id)sender {
    [self performSegueWithIdentifier:@"AddLocationSegue" sender:self];
}

#pragma mark - 
#pragma mark Segues

- (IBAction)returnToMap:(UIStoryboardSegue *)segue {
    self.navigationController.navigationBar.hidden=NO;
}

- (IBAction)friendDisclosureButton:(id)sender {
    [self performSegueWithIdentifier:@"ChooseFriendsSegue" sender:self];
}


@end
