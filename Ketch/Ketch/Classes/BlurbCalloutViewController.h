//
//  BlurbCalloutViewController.h
//  Ketch
//
//  Created by Andy Bayer on 4/28/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BlurbCalloutViewControllerDelegate <NSObject>
@required
- (void)dismissBlurbField:(NSString *)blurb;

@end

@interface BlurbCalloutViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *blurbField;
@property (strong, nonatomic) NSString *blurb;
@property (nonatomic, assign) id <BlurbCalloutViewControllerDelegate> delegate;
@end
