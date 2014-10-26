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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self isTextField:self.fieldType];
}
- (void)deleteRows {
    for( NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows  ) {
        NSDictionary *row = self.rows[indexPath.row];
        [[FieldsDataStore sharedInstance] redactValue:row[@"value"] forField:self.field];
    }
    NSIndexSet *indices = [self.tableView.indexPathsForSelectedRows indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return YES;
    }];
    [self.values removeObjectsAtIndexes:indices];
    [self initForm];
    [self.tableView reloadData];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteRows)];
}
- (void)initForm {
    _rows = [[NSMutableArray alloc] initWithCapacity:self.values.count];
    for( int i = 0; i < [self.form formSections].count; i++ ) {
        [self.form removeFormSectionAtIndex:i];
    }
    
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    for( id value in self.values ) {
        NSString *fieldType = types[self.fieldType];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:fieldType];
        BOOL isTextField = [self isTextField:fieldType];
        if(isTextField) {
            [row.cellConfig setObject:@NO forKey:@"textField.enabled"];
        }
        row.value = value;
        [_rows addObject:@{@"row": row, @"value": value}];
        [section addFormRow:row];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    return cell;
}
- (void)viewDidLoad {
    self.fieldType = self.field[@"typeName"];
    self.form = [XLFormDescriptor formDescriptorWithTitle:@"Field Values"];
    [self initForm];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
}

@end
