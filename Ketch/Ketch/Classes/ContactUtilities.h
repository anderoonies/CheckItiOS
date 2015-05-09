//
//  ContactUtilities.h
//  Ketch
//
//  Created by Andy Bayer on 2/22/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactUtilities : NSObject

- (NSString *)phoneToName:(NSString *)phone;
- (NSMutableArray *)getCleanNumbers;
- (NSMutableArray *)getContacts;
- (NSString *)cleanNumber:(NSString *)phoneNumber;

@end
