//
//  FriendAnnotation.h
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

// annotation that appears on the map of a friend object

@interface FriendAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *parseEvent;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSString *timeLabel;
@property (nonatomic, strong) NSString *blurb;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) BOOL didNotify;

- (NSString *)getInitials;

- (NSString *)getTimeLabel;

//- (id)initWithName:(NSString *)newName Location:(CLLocationCoordinate2D)location;

@end
