//
//  FormTableViewController.h
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideXLFormViewController.h"

@interface FormTableViewController : SlideXLFormViewController {
    NSMutableArray *altViews;
}

@property (nonatomic, strong) NSDictionary *formData;
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) NSString *formId;

@end
