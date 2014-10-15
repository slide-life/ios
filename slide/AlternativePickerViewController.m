//
//  AlternativePickerViewController.m
//  slide
//
//  Created by Matt Neary on 10/15/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "AlternativePickerViewController.h"

@implementation AlternativePickerViewController

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.data[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Set field value to another option.
    NSArray *data = self.data;
    void (^update)(NSString *) = self.update;
    update(data[row]);
}
- (AlternativePickerViewController *)initWithData: (NSArray *)data forUpdate: (void (^)(NSString *))update {
    self.data = data;
    self.update = update;
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [self.picker setDataSource:self];
    [self.picker setDelegate:self];
    self.picker.showsSelectionIndicator = YES;
    return self;
}

@end
