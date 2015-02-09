//
//  MapViewController.h
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NewEventView.h"
#import "WYPopoverController.h"
#import "CalloutViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, WYPopoverControllerDelegate> {
    IBOutlet MKMapView *mapView;
    WYPopoverController *popoverController;
}

//@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (nonatomic, strong) NSArray *friendList;

- (void)updateSubview;

@end

