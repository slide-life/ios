//
//  SlideXLFormViewController.h
//  slide
//
//  Created by Matt Neary on 10/25/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "XLFormViewController.h"

@interface SlideXLFormViewController : XLFormViewController {
    NSDictionary *types;
}
- (void)configureRow: (XLFormRowDescriptor *)row withType: (NSString *)type title: (NSString *)title andValue: (NSString *)value;
- (BOOL)isTextField: (NSString *)fieldType;
- (void)initialize;
- (NSArray *)uniqueValues: (NSArray *)values;
@end
