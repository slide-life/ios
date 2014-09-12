//
//  FormTableViewController.m
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "XLForm.h"
#import "FormTableViewController.h"

@implementation FormTableViewController

-(void)initForm {
    NSLog(@"%@", _formData);
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    NSArray *fields = _formData[@"fields"];
    for( NSDictionary *field in fields ) {
        NSDictionary *types = @{
          @"text": XLFormRowDescriptorTypeText,
          @"email": XLFormRowDescriptorTypeEmail
        };
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:types[field[@"type"]]];
        [row.cellConfigAtConfigure setObject:field[@"fieldName"] forKey:@"textField.placeholder"];
        [section addFormRow:row];
    }
    
    self.form = form;
}
- (void)viewDidLoad {
    [self initForm];
}

@end
