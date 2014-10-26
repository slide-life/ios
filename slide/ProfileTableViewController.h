//
//  ProfileTableViewController.h
//  slide
//
//  Created by Matt Neary on 10/22/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideXLFormViewController.h"

@interface ProfileTableViewController : SlideXLFormViewController <UISearchBarDelegate> {
    IBOutlet UISearchBar *searchbar;
    NSMutableArray *filteredFields;
}

@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) NSArray *fields;
@end
