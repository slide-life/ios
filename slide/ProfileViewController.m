//
//  ProfileViewController.m
//  slide
//
//  Created by Matt Neary on 1/13/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "ProfileViewController.h"
#import "FieldsDataStore.h"
#import "FieldValuesViewController.h"

@implementation ProfileViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = items[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return items.count;
}
- (void)viewDidLoad {
    [[FieldsDataStore sharedInstance] getProfileWithCallback:^(NSDictionary *profile) {
        self.profile = profile;
        items = profile.allKeys;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"showFieldValues"] ) {
        NSIndexPath *index = [self.tableView indexPathForCell:sender];
        ((FieldValuesViewController *)segue.destinationViewController).values = self.profile[items[index.row]];
    }
}

@end
