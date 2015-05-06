//
//  ContactUtilities.m
//  Ketch
//
//  Created by Andy Bayer on 2/22/15.
//  Copyright (c) 2015 Andy Bayer. All rights reserved.
//

#import "ContactUtilities.h"
#import <AddressBook/AddressBook.h>

@implementation ContactUtilities

- (NSString *)phoneToName:(NSString *)friendNumber {
    NSString *contactName = [[NSString alloc] init];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            if ([[phoneNumber substringToIndex:1] isEqualToString:@"1"]) {
                phoneNumber = [@"+" stringByAppendingString:phoneNumber];
            } else if(![[phoneNumber substringToIndex:1] isEqual:@"+"]) {
                phoneNumber = [@"+1" stringByAppendingString:phoneNumber];
            }
            
            // get rid of all characters for consistency in lookups
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()  -."]] componentsJoinedByString:@""];
            
            if ([phoneNumber isEqualToString:friendNumber]) {
                if (lastName) {
                    contactName = [firstName stringByAppendingString:[@" " stringByAppendingString:lastName]];
                } else {
                    contactName = firstName;
                }
                return contactName;
            }
        }
    }
    
    return nil;
}

- (NSMutableArray *)getCleanNumbers {
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:numberOfPeople];

    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );

        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            if ([[phoneNumber substringToIndex:1] isEqualToString:@"1"]) {
                phoneNumber = [@"+" stringByAppendingString:phoneNumber];
            } else if(![[phoneNumber substringToIndex:1] isEqual:@"+"]) {
                phoneNumber = [@"+1" stringByAppendingString:phoneNumber];
            }
            
            // get rid of all characters for consistency in lookups
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()  -."]] componentsJoinedByString:@""];
            
            [numbers addObject:phoneNumber];
        }
    }
    
    return numbers;
}

@end
