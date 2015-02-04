
//
//  MapViewController.m
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import "MapViewController.h"
#import "FriendAnnotation.h"
#import "DetailViewController.h"
#import "FriendAnnotationView.h"
#import <Parse/Parse.h>

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (nonatomic, strong) UIPopoverController *bridgePopoverController;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;


@end


#pragma mark -

@implementation MapViewController

- (void)gotoDefaultLocation
{
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = 37.786996;
    newRegion.center.longitude = -122.440100;
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    [mapView setRegion:newRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    // hide navigation bar
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapView.delegate = self;
    
    // add gesture recognizer
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.longPressGestureRecognizer.minimumPressDuration = 1.0f;
    self.longPressGestureRecognizer.allowableMovement = 100.0f;
    
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
    
    // resizing
    mapView.frame = self.view.bounds;
    mapView.autoresizingMask = self.view.autoresizingMask;
    
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

    // create out annotations array (in this example only 2 for testing)
    self.mapAnnotations = [[NSMutableArray alloc] initWithCapacity:2];
    
    [self generateAnnotations];
    
    // remove any annotations that exist
    [mapView removeAnnotations:mapView.annotations];
    
    // add both annotations
    [mapView addAnnotations:self.mapAnnotations];
    
    [self gotoDefaultLocation];
}

- (void)generateAnnotations {

    FriendAnnotation *friend1 = [[FriendAnnotation alloc] init];
    friend1.name = @"Ando";
    friend1.coordinate = CLLocationCoordinate2DMake(37.791, -122.443);
    [friend1 createImage];
    
    FriendAnnotation *friend2 = [[FriendAnnotation alloc] init];
    friend2.name = @"Andro";
    friend2.coordinate = CLLocationCoordinate2DMake(37.91, -122.49);
    friend2.imageName = @"my_face2";
    
    // test Parse
    //    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //    testObject[@"foo"] = @"bar";
    //    [testObject saveInBackground];
    
    [self.mapAnnotations addObject:friend1];
    [self.mapAnnotations addObject:friend2];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[FriendAnnotation class]])
    {
        // create a friend annotation object from the clicked annotation to get the friend's name, etc.
        FriendAnnotation *friend = view.annotation;

        // dequeue a detail view controller to be used as the detail for that friend
        DetailViewController *detailVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        
        // set the detail view controller's name property to the friend's name
        detailVC.name = friend.name;
        
        // push to the detail view controller
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *returnedAnnotationView = nil;
    // in case it's the user location, we already have an annotation, so just return nil
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {

        if ([annotation isKindOfClass:[FriendAnnotation class]]) // for Golden Gate Bridge
        {

            returnedAnnotationView = [FriendAnnotation createViewAnnotationForMapView:mapView annotation:annotation];
            
            returnedAnnotationView.image = [self makeAnnotationImage:annotation];
//            returnedAnnotationView.image = [UIImage imageNamed:((FriendAnnotation *)annotation).imageName];

            ((FriendAnnotationView *)returnedAnnotationView).rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        }

    }
    
    return returnedAnnotationView;
}

- (UIImage *)makeAnnotationImage:(FriendAnnotation *)annotation
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, 30, 30);
    CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetAlpha(ctx, 0.9f);
    CGContextFillEllipseInRect(ctx, rect);
    
    UIImage *grayCircle = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(ctx);
    
    UILabel *initialLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,20,30)];
    initialLabel.text = @"some text";
    initialLabel.tintColor = [UIColor blackColor];

    return grayCircle;
}

-(UIImage *)addText:(UIImage *)img text:(NSString *)text1{
    int w = img.size.width;
    int h = img.size.height;
    //lon = h - lon;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1);
    char* text	= (char *)[text1 cStringUsingEncoding:NSASCIIStringEncoding];// "05/05/09";
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
    
    //rotate text
    CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( -M_PI/4 ));
    CGContextSetTextPosition(context, 4, 52);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}

#pragma mark -
#pragma mark Gestures

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender
{
    if ([sender isEqual:self.longPressGestureRecognizer]) {
        if (sender.state == UIGestureRecognizerStateBegan)
        {
            CGPoint touchLocation = [sender locationInView:mapView];
            
            CLLocationCoordinate2D coordinate;
            coordinate = [mapView convertPoint:touchLocation toCoordinateFromView:mapView];// how to convert this to a String or something else?
            NSLog(@"LongPress coordinate: latitude = %f, longitude  = %f", coordinate.latitude, coordinate.longitude);
        }
    }
}

#pragma mark -
#pragma mark Buttons

- (IBAction)pushSettings:(id)sender {
    [self performSegueWithIdentifier:@"LoginSegue" sender:sender];
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

}



@end
