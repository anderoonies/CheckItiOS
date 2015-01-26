//
//  NewUserViewController.h
//  Ping2
//
//  Created by Andy Bayer on 1/26/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewUserViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordAgainField;

@end
