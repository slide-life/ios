//
//  ProfileViewController.h
//  slide
//
//  Created by Matt Neary on 10/3/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@interface ProfileViewController : UITableViewController <UITableViewDataSource> {
    ABAddressBookRef addressBook;
    NSMutableArray *fields;
}

@end
