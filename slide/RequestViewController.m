//
//  RequestViewController.m
//  slide
//
//  Created by Matt Neary on 11/30/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "RequestViewController.h"
#import "FieldsDataStore.h"
#import "API.h"

@implementation RequestViewController

- (NSArray *)uniqueLiteralValues: (NSArray *)values {
    NSSet *uniq = [NSSet setWithArray:values];
    NSMutableArray *output = [[NSMutableArray alloc] initWithCapacity:values.count];
    for(NSString *elm in uniq) {
        [output addObject:[NSString stringWithFormat:@"\"%@\"", elm]];
    }
    return output;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:self.blocks.count];
    for( NSString *block in self.blocks ) {
        NSArray *matches = [self uniqueLiteralValues:[[FieldsDataStore sharedInstance] getField:block withConstraints:@[]]];
        [fields addObject:[NSString stringWithFormat:@"Forms.selectField('%@', [%@], true)", block, [matches componentsJoinedByString:@", "]]];
    }
    NSString *fieldList = [NSString stringWithFormat:@"Forms.populateForm([%@])", [fields componentsJoinedByString:@", "]];
    [web stringByEvaluatingJavaScriptFromString:fieldList];
}

- (void)confirm {
    NSError *error;
    NSDictionary *responses = [NSJSONSerialization JSONObjectWithData:[[web stringByEvaluatingJavaScriptFromString:@"Forms.serializeForm()"] dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:NSJSONReadingAllowFragments error:&error];
    [[FieldsDataStore sharedInstance] registerUserForm:@{@"name": @"Unknown"} forUser:@"Unknown" withPatch:responses];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responses options:NSJSONWritingPrettyPrinted error:&error] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *code = [NSString stringWithFormat:@"var e = Slide.crypto.encryptDataSync(%@, '%@'); JSON.stringify({fields: e.fields, cipherkey: e.cipherkey})", json, self.pubKey];
    NSString *encryptedJSON = [web stringByEvaluatingJavaScriptFromString:code];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:[encryptedJSON dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:NSJSONReadingAllowFragments error:&error];
    [[API sharedInstance] postPayload:payload forChannel:self.channelId onSuccess:^(id resp) {
        NSLog(@"resp: %@", resp);
    } onFailure:^(id resp) {
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];

    NSString *contents = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"form-template" ofType:@"html"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *slideForm = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slide-form" ofType:@"js"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *jquery = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *styles = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"styles" ofType:@"css"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *slide = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slide" ofType:@"js"]] encoding:NSStringEncodingConversionExternalRepresentation];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{slide-form.js}}" withString:slideForm];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{jquery.js}}" withString:jquery];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{styles.css}}" withString:styles];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{slide.js}}" withString:slide];
    web.delegate = self;
    [web loadHTMLString:contents baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
