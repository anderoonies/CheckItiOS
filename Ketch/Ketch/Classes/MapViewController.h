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

@interface MapViewController : UIViewController <MKMapViewDelegate, WYPopoverControllerDelegate> {
    GMSMapView *mapView_;
    WYPopoverController *popoverController;
}

//@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *eventCreateButton;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic, strong) NSMutableArray *friendList;

- (void)updateSubview;

@end

