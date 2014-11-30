//
//  RequestsViewController.m
//  slide
//
//  Created by Matt Neary on 11/16/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "RequestsViewController.h"
#import "FieldsDataStore.h"

@implementation RequestsViewController

- (void)getData:(NSNotification *)notification {
    NSLog(@"Get data");
    NSArray *data = notification.userInfo[@"bucket"][@"fields"];
    NSString *bucket = notification.userInfo[@"bucket"][@"id"];
    [[FieldsDataStore sharedInstance] insertRequest:@{@"data": data, @"bucket": bucket}];
    requests = [[FieldsDataStore sharedInstance] getRequests];
    [self.tableView reloadData];
    // TODO: jump to the detail request view which will use the new webview form.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    requests = [[FieldsDataStore sharedInstance] getRequests];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(getData:) name:@"notification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return requests.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = @"Request";
    return cell;
}

@end
