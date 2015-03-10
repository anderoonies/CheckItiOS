//
//  MapViewController.h
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "NewEventView.h"
#import "WYPopoverController.h"
#import "CalloutViewController.h"
#import "OwnCalloutViewController.h"
#import "ContactUtilities.h"
#import "CustomGMSMarker.h"

@interface MapViewController : UIViewController <GMSMapViewDelegate, MKMapViewDelegate, WYPopoverControllerDelegate> {
    GMSMapView *mapView_;
    WYPopoverController *popoverController;
}

//@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *eventCreateButton;
@property (strong, nonatomic) ContactUtilities *contactUtilities;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) NSTimer *fetchTimer;
@property (nonatomic, strong) NSMutableArray *friendList;
@property (nonatomic, strong) CustomGMSMarker *userMarker;

- (void)updateSubview;

@end

