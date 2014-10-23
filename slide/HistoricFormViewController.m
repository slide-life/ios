//
//  HistoricFormViewController.m
//  slide
//
//  Created by Matt Neary on 10/22/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "HistoricFormViewController.h"
#import "XLForm.h"

@implementation HistoricFormViewController

- (BOOL)isTextField: (NSString *)fieldType {
    return [fieldType isEqualToString:@"text"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"number"] || [fieldType isEqualToString:@"password"];
}
- (void)initForm {
    for( int i = 0; i < [self.form formSections].count; i++ ) {
        [self.form removeFormSectionAtIndex:i];
    }
    
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    for( NSDictionary *fieldValue in self.fieldValues ) {
        NSDictionary *types = @{
                                @"text": XLFormRowDescriptorTypeText,
                                @"email": XLFormRowDescriptorTypeEmail,
                                @"checkbox": XLFormRowDescriptorTypeBooleanSwitch,
                                @"date": XLFormRowDescriptorTypeDatePicker,
                                @"number": XLFormRowDescriptorTypePhone,
                                @"password": XLFormRowDescriptorTypePassword
                                };
        NSString *fieldType = types[fieldValue[@"field"][@"typeName"]];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:fieldType];
        BOOL isTextField = [self isTextField:fieldType];
        if(isTextField) {
            [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
            [row.cellConfig setObject:@NO forKey:@"textField.enabled"];
        }
        row.title = fieldValue[@"field"][@"name"];
        row.value = fieldValue[@"value"];
        [section addFormRow:row];
    }
}
- (void)viewDidLoad {
    self.form = [XLFormDescriptor formDescriptorWithTitle:@"Field Values"];
    [self initForm];
}

@end
