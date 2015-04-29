//
//  BlurbCalloutViewController.m
//  Ketch
//
//  Created by Andy Bayer on 4/28/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "BlurbCalloutViewController.h"

@interface BlurbCalloutViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation BlurbCalloutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blurb = [[NSString alloc] init];
    
    _blurbField.delegate = self;
    [self.blurbField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender
{
    self.blurb = self.blurbField.text;
    
    [self.delegate dismissBlurbField:self.blurb];
    
}

#pragma mark Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 25) ? NO : YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField //resign first responder for textfield
{
    [self.blurbField resignFirstResponder];
    
    _blurb = self.blurbField.text;
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

