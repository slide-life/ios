//
//  FormTableViewController.m
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "XLForm.h"
#import "FormTableViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "FieldsDataStore.h"

@implementation FormTableViewController

-(void)initForm {
    _rows = [[NSMutableArray alloc] initWithCapacity:((NSArray *) _formData[@"fields"]).count];
    
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
          @"checkbox": XLFormRowDescriptorTypeBooleanSwitch,
          @"date": XLFormRowDescriptorTypeDatePicker,
          @"number": XLFormRowDescriptorTypePhone,
          @"password": XLFormRowDescriptorTypePassword
        };
        NSString *fieldType = field[@"typeName"];
        if(fieldType) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:types[fieldType]];
            if( [fieldType isEqualToString:@"text"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"number"] || [fieldType isEqualToString:@"password"] ) {
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
            }
            row.title = field[@"fieldName"];
            NSArray *values = [[FieldsDataStore sharedInstance] getField:field[@"id"]];
            if(field[@"aliasId"]) {
                values = values.count ? values : [[FieldsDataStore sharedInstance] getField:field[@"aliasId"]];
            }
            if( values.count ) {
                row.value = values.lastObject;
            }
            [_rows addObject:@{@"row": row, @"field": field}];
            [section addFormRow:row];
        } else {
            NSLog(@"Ignoring field with unresolved type.");
        }
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeButton];
    row.title = @"SEND";
    row.tag = @"sendButton";
    [section addFormRow:row];
    [row.cellConfigAtConfigure setObject:[UIColor colorWithRed:0.18 green:0.75 blue:0.41 alpha:1.0] forKey:@"backgroundColor"];
    [row.cellConfigAtConfigure setObject:[UIColor whiteColor] forKey:@"textLabel.color"];
    self.form = form;
}
- (void)send: (id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *path = [NSString stringWithFormat:@"http://bonds.io:3000/forms/%@/responses", _formId];
    NSMutableDictionary *fieldValues = [[NSMutableDictionary alloc] initWithCapacity:_rows.count];
    for( NSDictionary *field in _rows ) {
        XLFormRowDescriptor *row = field[@"row"];
        NSDictionary *fieldInfo = field[@"field"];
        if(row.value) {
            fieldValues[fieldInfo[@"id"]] = row.value;
        }
    }
    [[FieldsDataStore sharedInstance] patch:fieldValues];
    [manager POST:path parameters:fieldValues success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIViewController *thanks = [self.storyboard instantiateViewControllerWithIdentifier:@"thanks"];
        NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [controllers removeLastObject];
        [controllers addObject:thanks];
        
        [self.navigationController setViewControllers:controllers animated:YES];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void)viewDidLoad {
    [self initForm];
    self.navigationItem.title = _formData[@"name"];
}
- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    if( [formRow.tag isEqualToString:@"sendButton"] ) {
        [self send:formRow];
    }
}

@end
