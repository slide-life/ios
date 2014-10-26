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

- (void)initForm {
    for( int i = 0; i < [self.form formSections].count; i++ ) {
        [self.form removeFormSectionAtIndex:i];
    }
    
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    for( NSDictionary *fieldValue in self.fieldValues ) {
        NSString *fieldType = types[fieldValue[@"field"][@"typeName"]];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:fieldType];
        [self configureRow:row withType:fieldType title:fieldValue[@"field"][@"name"] andValue:fieldValue[@"value"]];
        BOOL isTextField = [self isTextField:fieldType];
        if(isTextField) {
            [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
            [row.cellConfig setObject:@NO forKey:@"textField.enabled"];
        } else if( [fieldType isEqualToString:XLFormRowDescriptorTypeBooleanSwitch] ) {
            [row.cellConfig setObject:@NO forKey:@"switchControl.enabled"];
        }
        [section addFormRow:row];
    }
}
- (void)viewDidLoad {
    [self initialize];
    self.form = [XLFormDescriptor formDescriptorWithTitle:@"Field Values"];
    [self initForm];
}

@end
