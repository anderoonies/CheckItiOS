//
//  DetailViewController.h
//  Ping2
//
//  Created by Andy Bayer on 12/10/14.
//  Copyright (c) 2014 Andy Bayer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (nonatomic, strong) NSString *name;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
