//
//  Crypto.m
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "API.h"
#import "Crypto.h"
#import "TemplateLoader.h"

@implementation Crypto

static Crypto *sharedInstance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    if(!sharedInstance) {
        dispatch_once(&onceToken, ^{
            sharedInstance = [[Crypto alloc] init];
            sharedInstance.webview = [[UIWebView alloc] init];
            sharedInstance.webview.delegate = sharedInstance;
            sharedInstance.queue = [[NSMutableArray alloc] initWithCapacity:255];
            NSString *content = [TemplateLoader loadTemplate:@"<script>{{@jquery.js}}</script><script>{{@slide.js}}</script>" withVariables:@{}];
            [sharedInstance.webview loadHTMLString:content baseURL:nil];
        });
    }
    return sharedInstance;
}
- (void)performTask: (NSDictionary *)task withCallback: (void (^)(NSString *))cb {
    if( [task[@"type"] isEqualToString:@"encrypt"] ) {
        [self encrypt:task[@"payload"] withKey:task[@"key"] andCallback:cb];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    ready = YES;
    NSLog(@"ready");
    int index = self.queue.count - 1;
    for( NSDictionary *task in self.queue.reverseObjectEnumerator ) {
        [self performTask:task[@"task"] withCallback:task[@"callback"]];
        [self.queue removeObjectAtIndex:index];
        index -= 1;
    }
}
- (void)encrypt: (NSDictionary *)payload withKey: (NSString *)key andCallback: (void (^)(NSString *))cb {
    // NB: key is a pem
    NSError *error;
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&error] encoding:NSStringEncodingConversionExternalRepresentation];
    if( ready ) {
        cb([self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"JSON.stringify({fields: Slide.crypto.encryptData(%@, atob('%@')), blocks: []})", json, key]]);
    } else {
        NSLog(@"slide: %@", [self.webview stringByEvaluatingJavaScriptFromString:@"Slide.toString()"]);
        [self.queue addObject:@{@"task": @{@"type": @"encrypt", @"payload": payload, @"key": key}, @"callback": cb}];
    }
}

@end
