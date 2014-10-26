//
//  SlideXLFormViewController.m
//  slide
//
//  Created by Matt Neary on 10/25/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "SlideXLFormViewController.h"
#import "XLForm.h"

@implementation SlideXLFormViewController
- (NSArray *)uniqueValues: (NSArray *)values {
    NSMutableDictionary *hash = [[NSMutableDictionary alloc] initWithCapacity:values.count];
    for( NSDictionary *value in values ) {
        hash[value] = @YES;
    }
    return hash.allKeys;
}
- (BOOL)isTextField: (NSString *)fieldType {
    return [fieldType isEqualToString:@"text"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"number"] || [fieldType isEqualToString:@"password"];
}
- (void)configureRow: (XLFormRowDescriptor *)row withType: (NSString *)fieldType title: (NSString *)title andValue: (NSString *)value {
    if([self isTextField:fieldType]) {
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        [row.cellConfig setObject:[UIFont fontWithName:@"Helvetica" size:16] forKey:@"textField.font"];
        [row.cellConfig setObject:[UIColor grayColor] forKey:@"textField.textColor"];
        NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.alignment = NSTextAlignmentRight;
        style.firstLineHeadIndent = 0.0f;
        style.headIndent = 0.0f;
        style.tailIndent = -12.0f;
        
        if( value != nil ) {
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:value attributes:@{ NSParagraphStyleAttributeName : style}];
            [row.cellConfig setObject:attrText forKey:@"textField.attributedText"];
        }
    }
    row.title = [title uppercaseString];
    [row.cellConfig setObject:[UIFont fontWithName:@"Helvetica-Bold" size:12] forKey:@"textLabel.font"];
    if( value ) {
        //row.value = value;
    }
}
- (void)initialize {
    types = @{
      @"text": XLFormRowDescriptorTypeText,
      @"email": XLFormRowDescriptorTypeEmail,
      @"checkbox": XLFormRowDescriptorTypeBooleanSwitch,
      @"date": XLFormRowDescriptorTypeDatePicker,
      @"number": XLFormRowDescriptorTypePhone,
      @"password": XLFormRowDescriptorTypePassword
      };
}
@end
