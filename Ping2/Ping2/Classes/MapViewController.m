
//
//  ViewController.m
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import "MapViewController.h"
#import "FriendAnnotation.h"
#import "DetailViewController.h"
#import "FriendAnnotationView.h"

@interface MapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (nonatomic, strong) UIPopoverController *bridgePopoverController;

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
    
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    // create out annotations array (in this example only 3)
    self.mapAnnotations = [[NSMutableArray alloc] initWithCapacity:2];
    
    FriendAnnotation *friend1 = [[FriendAnnotation alloc] init];
    friend1.name = @"Ando";
    friend1.coordinate = CLLocationCoordinate2DMake(37.791, -122.443);
    friend1.imageName = @"my_face";
    
    FriendAnnotation *friend2 = [[FriendAnnotation alloc] init];
    friend2.name = @"Andro";
    friend2.coordinate = CLLocationCoordinate2DMake(39, -123);
    friend2.imageName = @"my_face2";
    
    [self.mapAnnotations addObject:friend1];
    [self.mapAnnotations addObject:friend2];
    
    // remove any annotations that exist
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // add all 3 annotations
    [self.mapView addAnnotations:self.mapAnnotations];
    
    [self gotoDefaultLocation];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // here we illustrate how to detect which annotation type was clicked on for its callout
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[FriendAnnotation class]])
    {
        FriendAnnotation *friend = view.annotation;

        DetailViewController *detailVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.name = friend.name;
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

            returnedAnnotationView = [FriendAnnotation createViewAnnotationForMapView:self.mapView annotation:annotation];
                        
            returnedAnnotationView.image = [UIImage imageNamed:((FriendAnnotation *)annotation).imageName];

            ((FriendAnnotationView *)returnedAnnotationView).rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        }

    }
    
    return returnedAnnotationView;
}





@end
