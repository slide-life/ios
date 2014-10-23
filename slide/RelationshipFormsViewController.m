//
//  RelationshipFormsViewController.m
//  slide
//
//  Created by Matt Neary on 10/22/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "XLForm.h"
#import "FieldsDataStore.h"
#import "RelationshipFormsViewController.h"
#import "HistoricFormViewController.h"

@implementation RelationshipFormsViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoricFormViewController *hfvc = [[HistoricFormViewController alloc] init];
    hfvc.fieldValues = [[FieldsDataStore sharedInstance] getFieldsForForm:self.forms[indexPath.row]];
    [self.navigationController pushViewController:hfvc animated:YES];
}
- (void)initForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Relationship Forms"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    for( NSDictionary *form in self.forms ) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"notes" rowType:XLFormRowDescriptorTypeText];
        [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
        [row.cellConfig setObject:@NO forKey:@"textField.enabled"];
        row.title = form[@"form"][@"name"];
        row.value = form[@"form"][@"time"];
        [section addFormRow:row];
    }
    self.form = form;
    self.form.delegate = self;
}
- (void)reload {
    [self initForm];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [self reload];
}
@end
