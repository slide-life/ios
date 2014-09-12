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
          @"email": XLFormRowDescriptorTypeEmail,
          @"checkbox": XLFormRowDescriptorTypeBooleanSwitch
        };
        NSString *fieldType = field[@"typeName"];
        if(fieldType) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:types[fieldType]];
            row.title = field[@"fieldName"];
            [section addFormRow:row];
        } else {
            NSLog(@"Ignoring field with unresolved type.");
        }
    }
    
    self.form = form;
}
- (void)viewDidLoad {
    [self initForm];
    self.navigationItem.title = _formData[@"name"];
}

@end
