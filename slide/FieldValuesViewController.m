//
//  FieldValuesViewController.m
//  slide
//
//  Created by Matt Neary on 10/22/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "FieldValuesViewController.h"
#import "FieldsDataStore.h"
#import "XLForm.h"
#import "AlternativePickerViewController.h"

@implementation FieldValuesViewController

- (void)initForm {
    _rows = [[NSMutableArray alloc] initWithCapacity:self.values.count];
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    for( id value in self.values ) {
        NSDictionary *types = @{
                                @"text": XLFormRowDescriptorTypeText,
                                @"email": XLFormRowDescriptorTypeEmail,
                                @"checkbox": XLFormRowDescriptorTypeBooleanSwitch,
                                @"date": XLFormRowDescriptorTypeDatePicker,
                                @"number": XLFormRowDescriptorTypePhone,
                                @"password": XLFormRowDescriptorTypePassword
                                };
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:types[self.fieldType]];
        row.value = value;
        [_rows addObject:@{@"row": row, @"value": value}];
        [section addFormRow:row];
    }
    
    self.form = form;
}
- (void)viewDidLoad {
    NSLog(@"%@", self.values);
    [self initForm];
}

@end
