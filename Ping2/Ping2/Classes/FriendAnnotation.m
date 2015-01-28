//
//  FriendAnnotation.m
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import "FriendAnnotation.h"
#import "FriendAnnotationView.h"

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


- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


+ (MKAnnotationView *)createViewAnnotationForMapView:(MKMapView *)mapView annotation:(id <MKAnnotation>)annotation
{
    //
    MKAnnotationView *returnedAnnotationView =
    [mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([FriendAnnotation class])];
    if (returnedAnnotationView == nil)
    {
        returnedAnnotationView =
        [[MKAnnotationView alloc] initWithAnnotation:annotation
                                     reuseIdentifier:NSStringFromClass([FriendAnnotation class])];
        
        // specify that the annotation can create the callout on tap
        returnedAnnotationView.canShowCallout = YES;
        
        // offset the annotation so that the bottom of the image rests on the correct coordinate
        returnedAnnotationView.centerOffset = CGPointMake( returnedAnnotationView.centerOffset.x + returnedAnnotationView.image.size.width/2, returnedAnnotationView.centerOffset.y - returnedAnnotationView.image.size.height/2 );
    }
    else
    {
        returnedAnnotationView.annotation = annotation;
    }
    
    return returnedAnnotationView;
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