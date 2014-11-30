//
//  RequestDetailsViewController.h
//  slide
//
//  Created by Matt Neary on 11/16/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableView;
}

- (IBAction)confirm;
@property NSArray *data;

@end
