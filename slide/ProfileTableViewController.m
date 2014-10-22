//
//  ProfileTableViewController.m
//  slide
//
//  Created by Matt Neary on 10/22/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "FieldsDataStore.h"
#import "XLForm.h"
#import "FieldValuesViewController.h"

@implementation ProfileTableViewController

- (NSArray *)uniqueValues: (NSArray *)values {
    NSMutableDictionary *hash = [[NSMutableDictionary alloc] initWithCapacity:values.count];
    for( NSDictionary *value in values ) {
        hash[value] = @YES;
    }
    return hash.allKeys;
}
- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow
{
    [super didSelectFormRow:formRow];
    FieldValuesViewController *fvvc = [self.storyboard instantiateViewControllerWithIdentifier:@"fieldValues"];
    NSDictionary *kvInfo;
    for( NSDictionary *row in _rows ) {
        if( row[@"row"] == formRow ) {
            kvInfo = row[@"kv"];
        }
    }
    fvvc.title = kvInfo[@"field"][@"name"];
    fvvc.values = [self uniqueValues:kvInfo[@"values"]];
    fvvc.fieldType = kvInfo[@"field"][@"typeName"];
    [self.navigationController pushViewController:fvvc animated:YES];
}
- (void)initForm {
    _rows = [[NSMutableArray alloc] initWithCapacity:self.fields.count];
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    for( NSDictionary *kv in self.fields ) {
        NSDictionary *field = kv[@"field"];
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
            BOOL isTextField = [fieldType isEqualToString:@"text"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"number"] || [fieldType isEqualToString:@"password"];
            if(isTextField) {
                [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                [row.cellConfig setObject:@NO forKey:@"textField.enabled"];
            }
            row.title = field[@"name"];
            NSArray *values = kv[@"values"];
            values = [self uniqueValues:values];
            row.value = values.lastObject;
            [_rows addObject:@{@"row": row, @"kv": kv}];
            [section addFormRow:row];
        } else {
            NSLog(@"Ignoring field with unresolved type.");
        }
    }
    self.form = form;
    self.form.delegate = self;
}
- (void)viewDidLoad {
    self.fields = [[FieldsDataStore sharedInstance] getMergedKVs];
    [self initForm];
}

@end
