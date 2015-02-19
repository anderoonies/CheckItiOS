//
//  CustomGMSMarker.h
//  Ping2
//
//  Created by Andy Bayer on 2/19/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "FriendAnnotation.h"

@interface CustomGMSMarker : GMSMarker

@property (nonatomic, strong) FriendAnnotation *annotation;

@end
