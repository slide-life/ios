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
#import "QRReaderViewController.h"

@implementation RequestsViewController

- (void)getData:(NSNotification *)notification {
    NSArray *data = notification.userInfo[@"channel"][@"blocks"];
    NSString *bucket = notification.userInfo[@"channel"][@"id"];
    NSDictionary *key = notification.userInfo[@"channel"][@"key"];
    [self addRequest:@{@"data": data, @"bucket": bucket, @"key": key}];
}

- (void)addRequest: (NSDictionary *)request {
    NSMutableDictionary *r = request.mutableCopy;
    r[@"timestamp"] = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    [[FieldsDataStore sharedInstance] insertRequest:r];
    requests = [[FieldsDataStore sharedInstance] getRequests].reverseObjectEnumerator.allObjects;
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
    
    requests = [[FieldsDataStore sharedInstance] getRequests].reverseObjectEnumerator.allObjects;
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
    double epochTime = [requests[indexPath.row][@"timestamp"] doubleValue] / 1000;
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:epochTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy – hh:mm:ss a"];

    cell.textLabel.text = [dateFormatter stringFromDate:epochNSDate];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RequestViewController *rvc = [self.storyboard instantiateViewControllerWithIdentifier:@"requestView"];
    rvc.blocks = requests[indexPath.row][@"data"];
    rvc.pubKey = requests[indexPath.row][@"key"];
    rvc.channelId = requests[indexPath.row][@"bucket"];
    [self.navigationController pushViewController:rvc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if( [segue.identifier isEqualToString:@"qrShow"] ) {
        QRReaderViewController *qvc = segue.destinationViewController;
        qvc.delegate = self;
    }
}

@end
