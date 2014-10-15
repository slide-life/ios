//
//  AlternativePickerViewController.h
//  slide
//
//  Created by Matt Neary on 10/15/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"

@interface AlternativePickerViewController : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
@property UIPickerView *picker;
@property NSArray *data;
@property (nonatomic, strong) void (^update)(NSString *);
- (AlternativePickerViewController *)initWithData: (NSArray *)data forUpdate: (void (^)(NSString *))update;
@end
