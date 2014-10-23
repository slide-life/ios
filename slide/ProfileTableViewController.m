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
- (BOOL)isTextField: (NSString *)fieldType {
    return [fieldType isEqualToString:@"text"] || [fieldType isEqualToString:@"email"] || [fieldType isEqualToString:@"number"] || [fieldType isEqualToString:@"password"];
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
    if( [self isTextField:kvInfo[@"field"][@"typeName"]] ) {
        fvvc.title = kvInfo[@"field"][@"name"];
        fvvc.values = [NSMutableArray arrayWithArray:[self uniqueValues:kvInfo[@"values"]]];
        fvvc.field = kvInfo[@"field"];
        [self.navigationController pushViewController:fvvc animated:YES];
    }
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
            BOOL isTextField = [self isTextField:fieldType];
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
- (void)reload {
    self.fields = [[FieldsDataStore sharedInstance] getMergedKVs];
    [self initForm];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [self reload];
}
- (void)viewDidAppear:(BOOL)animated {
    [self reload];
}

@end
