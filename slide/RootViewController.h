//
//  RootViewController.h
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormTableViewController.h"
#import "QRReaderViewController.h"

@interface RootViewController : UIViewController

@property (nonatomic, strong) FormTableViewController *formTableViewController;
@property (nonatomic, strong) QRReaderViewController *QRReaderViewController;

@end
