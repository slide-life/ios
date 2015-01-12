//
//  Crypto.m
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "API.h"
#import "JSON.h"
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
    } else if( [task[@"type"] isEqualToString:@"generateKeys"] ) {
        [self generateKeysWithCallback:cb];
    } else if( [task[@"type"] isEqualToString:@"decryptKey"] ) {
        [self decryptSymmetricKey:task[@"key"] withCallback:cb];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    ready = YES;
    NSLog(@"ready");
    int index = (int)self.queue.count - 1;
    for( NSDictionary *task in self.queue.reverseObjectEnumerator ) {
        [self performTask:task[@"task"] withCallback:task[@"callback"]];
        [self.queue removeObjectAtIndex:index];
        index -= 1;
    }
}
- (void)encrypt: (NSDictionary *)payload withKey: (NSString *)key andCallback: (void (^)(NSString *))cb {
    // NB: key is a pem
    NSString *json = [JSON serialize:payload];
    if( ready ) {
        cb([self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"JSON.stringify({fields: Slide.crypto.AES.encryptData(%@, '%@'), blocks: []})", json, key]]);
    } else {
        [self.queue addObject:@{@"task": @{@"type": @"encrypt", @"payload": payload, @"key": key}, @"callback": cb}];
    }
}
- (void)generateKeysWithCallback: (void (^)(NSString *))cb {
    if( ready ) {
        NSString *keyString = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var keys; Slide.crypto.generateKeys(function(k) {keys = k;}); JSON.stringify(Slide.crypto.packKeys(keys))"]];
        cb(keyString);
    } else {
        [self.queue addObject:@{@"task": @{@"type": @"generateKeys"}, @"callback": cb}];
    }
}
- (void)decryptSymmetricKey: (NSString *)key withCallback: (void (^)(NSString *))cb {
    if( ready ) {
        NSString *privateKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"privateKey"];
        NSString *keyString = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Slide.crypto.decryptStringWithPackedKey('%@', '%@')", key, privateKey]];
        cb(keyString);
    } else {
        [self.queue addObject:@{@"task": @{@"type": @"decryptKey", @"key": key}, @"callback": cb}];
    }
}

@end
