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
- (void)performJob: (NSDictionary *)job {
    void (^task)() = job[@"task"];
    task();
}
- (void)addJob: (NSDictionary *)job {
    if( ready ) {
        void (^task)() = job[@"task"];
        task();
    } else {
        [self.queue addObject:job];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    ready = YES;
    int index = (int)self.queue.count - 1;
    for( NSDictionary *job in self.queue.reverseObjectEnumerator ) {
        [self performJob:job];
        [self.queue removeObjectAtIndex:index];
        index -= 1;
    }
}
- (void)encryptString: (NSString *)string withKey: (NSString *)key andCallback: (void (^)(NSString *))cb {
    void (^task)() = ^{
        cb([self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Slide.crypto.AES.encrypt('%@', '%@')", string, key]]);
    };
    [self addJob:@{@"task": task}];
}
- (void)encrypt: (NSDictionary *)payload withKey: (NSString *)key andCallback: (void (^)(NSString *))cb {
    void (^task)() = ^{
        NSString *json = [JSON serialize:payload];
        cb([self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"JSON.stringify({fields: Slide.crypto.AES.encryptData(%@, '%@'), blocks: []})", json, key]]);
    };
    [self addJob:@{@"task": task}];
}
- (void)decryptPackedString: (NSString *)payload withKey: (NSString *)key andCallback: (void (^)(NSString *))cb {
    void (^task)() = ^{
        cb([self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Slide.crypto.AES.decrypt(atob('%@'), '%@')", payload, key]]);
    };
    [self addJob:@{@"task": task}];
}
- (void)decryptData: (NSDictionary *)payload withKey: (NSString *)key andCallback: (void (^)(NSDictionary *))cb {
    void (^task)() = ^{
        NSString *data = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"JSON.stringify(Slide.crypto.AES.decryptData(%@, '%@'))", [JSON serialize:payload], key]];
        cb([JSON deserializeObject:data]);
    };
    [self addJob:@{@"task": task}];
}
- (void)generateKeysWithCallback: (void (^)(NSString *))cb {
    void (^task)() = ^{
        NSString *keyString = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"var keys; Slide.crypto.generateKeys(function(k) {keys = k;}); JSON.stringify(Slide.crypto.packKeys(keys))"]];
        cb(keyString);
    };
    [self addJob:@{@"task": task}];
}
- (void)generateSymmetricKey: (void (^)(NSString *))cb {
    void (^task)() = ^{
        NSString *keyString = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Slide.crypto.AES.generateKey();"]];
        cb(keyString);
    };
    [self addJob:@{@"task": task}];
}
- (void)decryptSymmetricKey: (NSString *)key withCallback: (void (^)(NSString *))cb {
    void (^task)() = ^{
        NSString *privateKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"privateKey"];
        NSString *keyString = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Slide.crypto.decryptStringWithPackedKey('%@', '%@')", key, privateKey]];
        cb(keyString);
    };
    [self addJob:@{@"task": task}];
}
- (void)encryptSymmetricKey: (NSString *)key withCallback: (void (^)(NSString *))cb {
    void (^task)() = ^{
        NSString *publicKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"publicKey"];
        NSString *keyString = [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Slide.crypto.encryptStringWithPackedKey('%@', '%@')", key, publicKey]];
        cb(keyString);
    };
    [self addJob:@{@"task": task}];
}

@end
