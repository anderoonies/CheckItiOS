//
//  MapViewController.h
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
}

//@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end

