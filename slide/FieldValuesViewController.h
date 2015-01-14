//
//  FieldValuesViewController.h
//  slide
//
//  Created by Matt Neary on 1/13/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FieldValuesViewController : UIViewController {
    IBOutlet UIWebView *web;
}

@property NSArray *values;
@end
