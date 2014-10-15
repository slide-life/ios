//
//  WalletViewController.m
//  slide
//
//  Created by Matt Neary on 10/15/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "WalletViewController.h"
#import "FieldsDataStore.h"

@implementation WalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    forms = [[FieldsDataStore sharedInstance] getForms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return forms.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSString *form = forms[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Form %@", form];
    return cell;
}

@end
