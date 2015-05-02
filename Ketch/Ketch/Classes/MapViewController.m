
//
//  MapViewController.m
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

// some icons from http://www.flaticon.com/authors/icons8 from http://www.flaticon.com, licensed by http://creativecommons.org/licenses/by/3.0/

#import "MapViewController.h"
#import "FriendAnnotation.h"
#import "UserAnnotation.h"
#import "FriendAnnotationView.h"
#import <GoogleMaps/GMSMarker.h>
#import "ContactUtilities.h"
#import "CalloutViewController.h"
#import "InviteFriendTableViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface MapViewController () <GMSMapViewDelegate, WYPopoverControllerDelegate>

@property (nonatomic, strong) NSMutableArray *mapMarkers;
@property (nonatomic, strong) NSMutableArray *parseEvents;
@property (nonatomic, strong) UIPopoverController *bridgePopoverController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) UserAnnotation *userAnnotation;
@property (nonatomic, strong) NSString *blurb;

@end


#pragma mark -

@implementation MapViewController {
    BOOL firstLocationUpdate_;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self generateAnnotations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    _contactUtilities = [[ContactUtilities alloc] init];
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:60.0f target:self selector:@selector(generateAnnotations) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.fetchTimer = timer;
    
    _userAnnotation = [[UserAnnotation alloc] init];
    _userAnnotation.name = @"Me";
    
    _userMarker = [[CustomGMSMarker alloc] init];
    _userMarker.annotation = _userAnnotation;
    _userMarker.icon = [self makeAnnotationImage:_userAnnotation];
    _userMarker.groundAnchor = CGPointMake(0.5, 0.5);
    
    // create out annotations array (in this example only 2 for testing)
    self.mapMarkers = [[NSMutableArray alloc] initWithCapacity:2];
    
    [self generateAnnotations];
    
    [self gotoStartLocation];
    
    [mapView_ animateToLocation:mapView_.myLocation.coordinate];

    [self.view insertSubview:mapView_ atIndex:0];
    
    self.eventCreateSubview = [[[[NSBundle mainBundle] loadNibNamed:@"NewEventView" owner:self options:nil] objectAtIndex:0] initWithFrame:CGRectMake(0, self.view.frame.size.height-210, self.view.frame.size.width, 210)];
    
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
    
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    mapView_.delegate = self;
    
    // remove any annotations that exist
    [mapView_ clear];
    
    for (FriendAnnotation *annotation in _mapMarkers) {
        CustomGMSMarker *marker = [CustomGMSMarker markerWithPosition:annotation.coordinate];
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [self makeAnnotationImage:annotation];
        marker.title = [annotation getInitials];
        marker.snippet = [annotation getTimeLabel];
        marker.annotation = annotation;
        marker.groundAnchor = CGPointMake(0.5, 0.5);
        marker.map = mapView_;
    }
}

- (void)generateAnnotations {
    if ([PFUser currentUser]==nil) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
        return;
    }
        
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"event"];
    [eventQuery whereKey:@"canSee" equalTo:[PFUser currentUser]];
    [eventQuery whereKey:@"endTime" greaterThan:[NSDate date]];
    
    PFQuery *userEvent = [PFQuery queryWithClassName:@"event"];
    [userEvent whereKey:@"user" equalTo:[PFUser currentUser]];
    [userEvent whereKey:@"endTime" greaterThan:[NSDate date]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[eventQuery, userEvent]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [mapView_ clear];
            for (PFObject *object in objects) {
                FriendAnnotation *annotation;
                if (object[@"user"]==[PFUser currentUser]) {
                    annotation = [[UserAnnotation alloc] init];
                    annotation.name = @"Me";
                    annotation.startTime = object[@"startTime"];
                    annotation.endTime = object[@"endTime"];
                    annotation.blurb = object[@"blurb"];
                    PFGeoPoint *geoPoint = object[@"location"];
                    annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                } else {
                    annotation = [[FriendAnnotation alloc] init];
                    annotation.parseEvent = object;
                    PFObject *creator = [object[@"user"] fetchIfNeeded];
                    annotation.name = [_contactUtilities phoneToName:creator[@"phone"]];
                    if (annotation.name==nil) {
                        annotation.name = creator[@"username"];
                    }
                    annotation.startTime = object[@"startTime"];
                    annotation.endTime = object[@"endTime"];
                    annotation.blurb = object[@"blurb"];
                    PFGeoPoint *geoPoint = object[@"location"];
                    if ([[object valueForKey:@"nudgers"] containsObject:[PFUser currentUser]]) {
                        annotation.didNotify=YES;
                    }
                    annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    annotation.user = (PFUser *)object[@"user"];
                }
                
                CustomGMSMarker *marker = [CustomGMSMarker markerWithPosition:CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude)];
                marker.appearAnimation = kGMSMarkerAnimationPop;
                marker.icon = [self makeAnnotationImage:annotation];
                marker.title = [annotation getInitials];
                marker.snippet = [annotation getTimeLabel];
                marker.annotation = annotation;
                marker.groundAnchor = CGPointMake(0.5, 0.5);
                
                if ([annotation isKindOfClass:[UserAnnotation class]]) {
                    _userAnnotation = (UserAnnotation *)annotation;
                    _userMarker.annotation = (UserAnnotation *)annotation;
                    _userMarker.position = annotation.coordinate;
                    _userMarker.map = mapView_;
                } else {
                    marker.map = mapView_;
                    [_mapMarkers addObject:marker];
                }
            }
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
//    **Deletion was moved to a BG job within Parse**
    
//    PFQuery *deleteQuery = [PFQuery queryWithClassName:@"event"];
//    [deleteQuery whereKey:@"endTime" lessThan:[NSDate date]];
//    [deleteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            for (PFObject *object in objects) {
//                [object deleteInBackground];
//            }
//        }
//    }];
}

- (void)gotoStartLocation
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

- (void)gotoUserLocation {
    CLLocation *myLocation = self.locationManager.location;
    myLocation = mapView_.myLocation;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocation.coordinate.latitude
                                                            longitude:myLocation.coordinate.longitude
                                                                 zoom:17];
    
    mapView_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
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

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint p = [mapView.projection pointForCoordinate:coordinate];
    
    for (UIView *aView in [self.view subviews]) {
        if (([aView isKindOfClass:[NewEventView class]])&&(!CGRectContainsPoint(aView.frame, p)))
        {
            [self hideMarkerButton];
            [self hideSubview];
        }
    }
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:17];
        [mapView_ animateToViewingAngle:60];

    }
}

#pragma mark -
#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [mapView_ animateToLocation:[[locations lastObject] coordinate]];
}

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
    CustomGMSMarker *senderMarker = [[CustomGMSMarker alloc] init];
    senderMarker = (CustomGMSMarker *) sender;
    
    FriendAnnotation *annotation = senderMarker.annotation;
    CalloutViewController *calloutVC = [[CalloutViewController alloc] init];
    
    calloutVC.blurbLabel.numberOfLines = 0;
    
    
    if ([annotation.blurb length]) {
        calloutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CalloutViewController"];
        calloutVC.preferredContentSize = CGSizeMake(200, 80);
    } else {
        calloutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CalloutViewControllerNoBlurb"];
        calloutVC.preferredContentSize = CGSizeMake(200, 50);
    }
    
    
    if (popoverController == nil)
    {
        calloutVC.annotation = annotation;
        calloutVC.mapVC = self;
        
        if ([[(CustomGMSMarker *)sender annotation] isKindOfClass:[UserAnnotation class]]) {
            calloutVC.own = YES;
            calloutVC.nameLabelValue = _userMarker.annotation.name;
            calloutVC.timeLabelValue = [_userMarker.annotation getTimeLabel];
            calloutVC.blurbLabelValue = _userMarker.annotation.blurb;
        } else {
            calloutVC.own = NO;
            calloutVC.nameLabelValue = annotation.name;
            calloutVC.timeLabelValue = [annotation getTimeLabel];
            calloutVC.blurbLabelValue = annotation.blurb;
            
            if (annotation.didNotify) {
                calloutVC.notifyButtonColor = [UIColor colorWithRed:(95/255.0) green:(201/255.0) blue:(56/255.0) alpha:1.0];
            }
        }
        
        popoverController = [[WYPopoverController alloc] initWithContentViewController: calloutVC];
        
        popoverController.delegate = self;
        
        CGPoint annotation_point = [mapView_.projection pointForCoordinate:senderMarker.position];
        
        [popoverController presentPopoverFromRect:CGRectMake(annotation_point.x - senderMarker.icon.size.width/2, annotation_point.y - senderMarker.icon.size.height/2, senderMarker.icon.size.width, senderMarker.icon.size.height) inView:mapView_ permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES options:WYPopoverAnimationOptionFadeWithScale];
    } else {
        [self close:nil];
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
}

- (void)close:(id)sender
{
    [popoverController dismissPopoverAnimated:YES completion:^{
        [self popoverControllerDidDismissPopover:popoverController];
    }];
    
}

#pragma mark -
#pragma mark Gestures

- (IBAction)addEventButtonPress:(id)sender
{
    self.eventCreateButton.enabled = NO;
    self.settingsButton.enabled = NO;
    
    CGPoint point = [mapView_.projection pointForCoordinate:mapView_.camera.target];
    CLLocationCoordinate2D center = mapView_.camera.target;
    
    _userAnnotation.coordinate = center;
    
    UIButton *markerButton = [[UIButton alloc] init];
    markerButton.tag = 3;
    markerButton.enabled = NO;
    
    [markerButton setImage:_userMarker.icon forState:UIControlStateNormal];
    
    
    CGRect endFrame = CGRectMake(point.x-_userMarker.icon.size.width / 2, point.y-_userMarker.icon.size.height / 2, _userMarker.icon.size.width, _userMarker.icon.size.height);
    
    CGRect startFrame = CGRectMake(point.x-_userMarker.icon.size.width / 2, 0, _userMarker.icon.size.width, _userMarker.icon.size.width);
    
    markerButton.frame = startFrame;
    
    [self.view addSubview:markerButton];
    
    [UIView animateWithDuration:0.5
                     animations:^{ markerButton.frame = endFrame; }];
    
    [self showSubview];
    
}

- (IBAction)deletePressed:(id)sender {
    
}

#pragma mark -
#pragma mark New Event Subview

- (void)showSubview {
    [self.view addSubview:self.eventCreateSubview];
    
    if ([_friendList count]==0) {
        self.eventCreateSubview.createButton.alpha = 0.4f;
        self.eventCreateSubview.createButton.enabled = NO;
    }
    
    self.eventCreateSubview.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.eventCreateSubview.frame.size.height);
    [UIView animateWithDuration:.5
                     animations:^{
                         self.eventCreateSubview.frame = CGRectMake(0,
                                                         self.view.frame.size.height - self.eventCreateSubview.frame.size.height,
                                                         self.view.frame.size.width,
                                                         self.eventCreateSubview.frame.size.height);
                     }
     ];
}

- (void)hideSubview {
    [UIView animateWithDuration:.25
                     animations:^{
                         self.eventCreateSubview.frame = CGRectMake(0,
                                                         self.view.frame.size.height,
                                                         self.view.frame.size.width,
                                                         self.eventCreateSubview.frame.size.height);
                     }
                     completion:^(BOOL finished){ [self.eventCreateSubview removeFromSuperview];
                                                     self.eventCreateButton.enabled = YES;
                                                     self.settingsButton.enabled = YES;
                                                }
     ];
}

- (void)hideMarkerButton {
    UIView *markerButton = [self.view viewWithTag:3];
    CGRect startFrame = CGRectMake(CGRectGetMaxX(markerButton.frame)-_userMarker.icon.size.width / 2, 0, _userMarker.icon.size.width, _userMarker.icon.size.width);

    [UIView animateWithDuration:0.5
                     animations:^{ markerButton.frame = startFrame; }
                     completion:^(BOOL finished){ [markerButton removeFromSuperview];  }
     ];
}

- (void)updateSubview {
    NSMutableArray *friendStrings = [[NSMutableArray alloc] init];
    ContactUtilities *contactUtilities = [[ContactUtilities alloc] init];
    if ([_friendList count]==0) {
        self.eventCreateSubview.friendListLabel.text = @"INVITE FRIENDS";
    } else {
        self.eventCreateSubview.createButton.enabled = YES;
        self.eventCreateSubview.createButton.alpha = 1.0f;
        for (PFObject *object in _friendList) {
            if (object[@"phone"]) {
                NSString *phone = [contactUtilities phoneToName:object[@"phone"]];
                if (phone) {
                    [friendStrings addObject:phone];
                } else {
                    [friendStrings addObject:object[@"username"]];
                }
            } else {
                [friendStrings addObject:object[@"username"]];
            }
        }
        
        self.eventCreateSubview.friendListLabel.text = [friendStrings componentsJoinedByString:@", "];
        self.eventCreateSubview.friendListLabel.textColor = [UIColor blackColor];
    }
}

- (IBAction)createEventPressed:(id)sender {
    if ([_friendList count]==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error:" message:@"Please select friends" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    CLLocationCoordinate2D centerCoord = mapView_.camera.target;
    
    
    PFObject *event = [PFObject objectWithClassName:@"event"];
    NSDate *curDate = [NSDate date];
    NSInteger seconds = 60;
    NSInteger minutes = self.eventCreateSubview.minutes;
    NSTimeInterval interval = minutes * seconds;
    NSDate *endDate = [curDate dateByAddingTimeInterval:interval];
    event[@"user"] = [PFUser currentUser];
    event[@"startTime"] = curDate;
    event[@"endTime"] = endDate;
    event[@"canSee"] = _friendList;
    event[@"blurb"] = _blurb;
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
    event[@"location"] = point;
    event[@"nudgers"] = [[NSMutableArray alloc] initWithObjects:nil];

    
    UserAnnotation *annotation = [[UserAnnotation alloc] init];
    annotation.name = @"Me";
    annotation.startTime = curDate;
    annotation.endTime = endDate;
    annotation.coordinate = CLLocationCoordinate2DMake(centerCoord.latitude, centerCoord.longitude);
    annotation.blurb = _blurb;
    
    _userAnnotation.coordinate = centerCoord;
    _userMarker.position = centerCoord;
    _userMarker.map = mapView_;
    _userMarker.annotation = annotation;
    
    [[self.view viewWithTag:3] removeFromSuperview];
    [self.eventCreateSubview.blurbImageView setImage:[UIImage imageNamed:@"speech95.png"]];
    [self hideSubview];
    
    // remove user's previous event
    PFQuery *userEvent = [PFQuery queryWithClassName:@"event"];
    [userEvent whereKey:@"user" equalTo:[PFUser currentUser]];
    [userEvent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [object delete];
            }
        }
    }];
    
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved object");
        } else {
            NSLog(@"FATAL ERROR %@", error);
        }
    }];
}

- (IBAction)blurbControlPressed:(id)sender {
    BlurbCalloutViewController *calloutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BlurbCalloutViewController"];
    
    calloutVC.delegate = self;
    
    if ([self.blurb length]) {
        calloutVC.blurb = self.blurb;
    }
    
    calloutVC.preferredContentSize = CGSizeMake(self.view.frame.size.width, 55);

    if (popoverController == nil)
    {
        popoverController = [[WYPopoverController alloc] initWithContentViewController: calloutVC];
        
        popoverController.delegate = self;
        
        [popoverController presentPopoverFromRect:CGRectMake(self.eventCreateSubview.frame.origin.x+25,
                                                             self.eventCreateSubview.frame.origin.y,
                                                             10,
                                                             10)
                                                inView:self.view
                                                permittedArrowDirections:WYPopoverArrowDirectionDown
                                                animated:YES
                                                options:WYPopoverAnimationOptionFadeWithScale];
    } else {
        [self close:nil];
    }

}

#pragma mark -
#pragma mark Blurb Delegate

- (void)dismissBlurbField:(NSString *)blurb
{
    [self close:nil];
    _blurb = blurb;
    if ([_blurb length]) {
        [self.eventCreateSubview.blurbImageView setImage:[UIImage imageNamed:@"filledspeech95.png"]];
    } else {
        [self.eventCreateSubview.blurbImageView setImage:[UIImage imageNamed:@"speech95.png"]];
    }
}

#pragma mark -
#pragma mark Buttons

- (IBAction)settingsPressed:(id)sender {
    if (![PFUser currentUser]) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"SettingsSegue" sender:self];
    }
}

#pragma mark - 
#pragma mark Segues

- (IBAction)returnToMap:(UIStoryboardSegue *)segue {
    self.navigationController.navigationBar.hidden=NO;
}

- (IBAction)friendDisclosureButton:(id)sender {
    [self performSegueWithIdentifier:@"ChooseFriendsSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[InviteFriendTableViewController class]]) {
        InviteFriendTableViewController* inviteVC = (InviteFriendTableViewController *)[segue destinationViewController];
        inviteVC.friendList = [[NSMutableArray alloc] init];
        [inviteVC passFriendList:_friendList];
    }
}

#pragma mark -
#pragma mark Keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    
    [popoverController presentPopoverFromRect:CGRectMake(self.eventCreateSubview.frame.origin.x+25,
                                                         (self.eventCreateSubview.frame.origin.y - (kbSize.height - self.eventCreateSubview.frame.origin.y)),
                                                         10,
                                                         10)
                                       inView:self.view
                     permittedArrowDirections:WYPopoverArrowDirectionDown
                                     animated:NO];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboard hding");
}

@end
