//
//  ProfileViewController.m
//  slide
//
//  Created by Matt Neary on 10/3/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "ProfileViewController.h"
#import "FieldsDataStore.h"
#import <AddressBook/AddressBook.h>

@implementation ProfileViewController

- (void)_queryContacts: (NSString *)q {
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    int allPeopleCount = (int)CFArrayGetCount(allPeople);
    for( int i = 0; i < allPeopleCount; i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(allPeople,i);
        ABMultiValueRef *phoneProperty = (ABMultiValueRef *)ABRecordCopyValue(record, kABPersonPhoneProperty);
        NSArray *phones = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(phoneProperty);
        for( NSString *phone in phones ) {
            NSCharacterSet *nonNumeral = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            NSString *number = [[phone componentsSeparatedByCharactersInSet:nonNumeral] componentsJoinedByString:@""];
            if( [number hasSuffix:q] ) {
                NSString *firstName = (__bridge NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
                NSString *lastName = (__bridge NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
                NSArray *addressDicts = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(record, kABPersonAddressProperty));
                NSDictionary *addressFields = addressDicts[0];
                // TODO: How can we take these values and fill them
                // in for the appropriate ID keys in the keystore.
                [fields addObject:@{@"value": firstName, @"field": @"First Name"}];
                [fields addObject:@{@"value": lastName, @"field": @"Last Name"}];
                [fields addObject:@{@"value": addressFields[@"City"], @"field": @"City"}];
                [fields addObject:@{@"value": addressFields[@"State"], @"field": @"State"}];
                [fields addObject:@{@"value": addressFields[@"Country"], @"field": @"Country"}];
                [fields addObject:@{@"value": addressFields[@"Street"], @"field": @"Street Address"}];
                [fields addObject:@{@"value": addressFields[@"ZIP"], @"field": @"Zip Code"}];
                [self.tableView reloadData];
            }
        }
    }
}
- (void)query: (NSString *)q {
    // TODO: Let him first enter his phone number and explain why we are accessing contacts.
    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, query who he is.
                [self _queryContacts:q];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, query who he is.
        [self _queryContacts:q];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *phone = [alertView textFieldAtIndex:0].text;
    [self query:phone];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    fields = [[NSMutableArray alloc] initWithCapacity:128];
    
    if( [[FieldsDataStore sharedInstance] getKVs].count == 0 ) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Your Phone Number" message:@"Please provide your phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.delegate = self;
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypePhonePad;
        alertTextField.placeholder = @"5555555555";
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return fields.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSDictionary *field = fields[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", field[@"field"], field[@"value"]];
    return cell;
}

@end
