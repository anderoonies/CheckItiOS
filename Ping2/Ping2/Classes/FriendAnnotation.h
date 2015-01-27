//
//  FriendAnnotation.h
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// annotation that appears on the map of a friend object

@interface FriendAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation;

//- (id)initWithName:(NSString *)newName Location:(CLLocationCoordinate2D)location;

@end
