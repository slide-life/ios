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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchbar.showsCancelButton = YES;
}
- (void)performSearch: (NSString *)searchText {
    filteredFields = [[NSMutableArray alloc] initWithCapacity:self.fields.count];
    for( NSDictionary *field in self.fields ) {
        if( [[field[@"field"][@"name"] lowercaseString] componentsSeparatedByString:searchText].count > 1 || [searchText isEqualToString:@""] ) {
            [filteredFields addObject:field];
        }
    }
    [self reloadForm];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self performSearch:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchbar.showsCancelButton = NO;
    [searchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchbar.text = @"";
    [self performSearch:@""];
    searchbar.showsCancelButton = NO;
    [searchbar resignFirstResponder];
}

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
    _rows = [[NSMutableArray alloc] initWithCapacity:filteredFields.count];
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    for( NSDictionary *kv in filteredFields ) {
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
- (void)reloadForm {
    [self initForm];
    [self.tableView reloadData];
}
- (void)reload {
    searchbar.text = @"";
    searchbar.showsCancelButton = NO;
    self.fields = [[FieldsDataStore sharedInstance] getMergedKVs];
    filteredFields = [NSMutableArray arrayWithArray:self.fields];
    [self reloadForm];
}
- (void)viewDidLoad {
    [self reload];
    searchbar.delegate = self;
}
- (void)viewDidAppear:(BOOL)animated {
    [self reload];
}

@end
