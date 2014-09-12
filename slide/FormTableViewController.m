//
//  FormTableViewController.m
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "FormTableViewController.h"
#import "XLFormViewController.h"

@interface FormTableViewController ()

@end

@implementation FormTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", _form);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

@end
