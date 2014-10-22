//
//  FieldValuesViewController.h
//  slide
//
//  Created by Matt Neary on 10/22/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"

@interface FieldValuesViewController : XLFormViewController

@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSString *fieldType;
@end
