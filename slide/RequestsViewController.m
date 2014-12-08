//
//  RequestsViewController.m
//  slide
//
//  Created by Matt Neary on 11/16/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "RequestsViewController.h"
#import "RequestViewController.h"
#import "FieldsDataStore.h"
#import "API.h"

@implementation RequestsViewController

- (void)getData:(NSNotification *)notification {
    NSLog(@"Get data: %@", notification.userInfo);
    NSArray *data = notification.userInfo[@"channel"][@"blocks"];
    NSString *bucket = notification.userInfo[@"channel"][@"id"];
    NSDictionary *key = notification.userInfo[@"channel"][@"key"];
    [[FieldsDataStore sharedInstance] insertRequest:@{@"data": data, @"bucket": bucket, @"timestamp": [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000], @"key": key}];
    requests = [[FieldsDataStore sharedInstance] getRequests];
    [self.tableView reloadData];
    // TODO: jump to the detail request view which will use the new webview form.
}

- (void)postToken: (NSNotification *)notification {
    NSData *token = notification.userInfo[@"token"];
    NSString *deviceToken = [[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    // TODO: check if device has been registered.
    if( NO ) {
        [[API sharedInstance] postDevice:deviceToken forUser:self.number onSuccess:^(id resp) {
            NSLog(@"success");
        } onFailure:^(id resp) {
            NSLog(@"failure: %@", resp);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( [[NSUserDefaults standardUserDefaults] objectForKey:@"number"] ) {
        self.number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
    } else {
        NSString *number = @"16144408217";
        [[NSUserDefaults standardUserDefaults] setObject:number forKey:@"number"];
        self.number = number;
    }
    
    requests = [[FieldsDataStore sharedInstance] getRequests];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(getData:) name:@"notification" object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(postToken:) name:@"deviceToken" object:nil];
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
    cell.textLabel.text = requests[indexPath.row][@"timestamp"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RequestViewController *rvc = [self.storyboard instantiateViewControllerWithIdentifier:@"requestView"];
    NSError *error;
    rvc.blocks = requests[indexPath.row][@"data"];
    rvc.pubKey = requests[indexPath.row][@"key"];
    rvc.channelId = requests[indexPath.row][@"bucket"];
    [self.navigationController pushViewController:rvc animated:YES];
}

@end
