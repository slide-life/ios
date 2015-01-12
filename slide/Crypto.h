//
//  Crypto.h
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crypto : NSObject <UIWebViewDelegate> {
    BOOL ready;
}

@property UIWebView *webview;
@property NSMutableArray *queue;
+ (instancetype)sharedInstance;
- (void)encrypt: (NSDictionary *)payload withKey: (NSString *)key andCallback: (void (^)(NSString *))cb;
@end
