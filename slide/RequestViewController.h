//
//  RequestViewController.h
//  slide
//
//  Created by Matt Neary on 11/30/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestViewController : UIViewController <UIWebViewDelegate> {
    IBOutlet UIWebView *web;
}

@property NSString *conversationId;
@property NSString *pubKey;
@property NSArray *blocks;

@end
