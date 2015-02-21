//
//  FriendAnnotation.m
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import "FriendAnnotation.h"
#import "FriendAnnotationView.h"
#import "UserAnnotation.h"


@implementation FriendAnnotation


// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return self.name;
}

// optional
- (NSString *)subtitle
{
    return @"subtitle";
}

- (NSString *)getInitials {
    NSMutableArray *initials = [[NSMutableArray alloc] init];
    NSArray *subnames = [self.name componentsSeparatedByString:@" "];
    for (NSString *substring in subnames) {
        if ([substring length]) {
            NSString *initial = [substring substringToIndex:1];
            [initials addObject:initial];
        }
    }
    
    return [initials componentsJoinedByString:@""];
}

- (NSString *)getTimeLabel
{
#define stdDateFormat @"h:mm"
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:stdDateFormat];
    NSString *startTimeString = [dateFormat stringFromDate:_startTime];
    
    NSString *endTimeString = [dateFormat stringFromDate:_endTime];
    
    return [NSString stringWithFormat:@"%@–%@", startTimeString, endTimeString];
}

//- (id)initWithName:(NSString *)newName Location:(CLLocationCoordinate2D)location
//{
//    self = [super init];
//    if (self) {
//        _name = newName;
//        _coordinate = location;
//        _imageName = @"my_face";
//    }
//    
//    return self;
//}

@end
