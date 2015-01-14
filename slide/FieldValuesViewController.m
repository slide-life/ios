//
//  FieldValuesViewController.m
//  slide
//
//  Created by Matt Neary on 1/13/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "FieldValuesViewController.h"

@implementation FieldValuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    web.opaque = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [web loadHTMLString:[self.values componentsJoinedByString:@", "] baseURL:nil];
}

@end
