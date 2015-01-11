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
#import "TemplateLoader.h"

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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)continueConfirm: (NSString *)encryptedJSON {
    NSError *error;
    NSData *data = [encryptedJSON dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    [[API sharedInstance] postPayload:payload forChannel:self.channelId onSuccess:^(id resp) {
        NSLog(@"resp: %@", resp);
    } onFailure:^(NSURLResponse *resp) {
        NSLog(@"failed: %@", resp);        
    }];
}

- (void)confirm {
    NSError *error;
    NSDictionary *responses = [NSJSONSerialization JSONObjectWithData:[[web stringByEvaluatingJavaScriptFromString:@"Forms.serializeForm()"] dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:NSJSONReadingAllowFragments error:&error];
    [[FieldsDataStore sharedInstance] registerUserForm:@{@"name": @"Unknown"} forUser:@"Unknown" withPatch:responses];
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responses options:NSJSONWritingPrettyPrinted error:&error] encoding:NSStringEncodingConversionExternalRepresentation];
    web.delegate = self;
    NSString *pem = self.pubKey;
    NSString *code = [NSString stringWithFormat:@"JSON.stringify({fields: Slide.crypto.encryptData(%@, forge.util.decode64('%@')), blocks: []})", json, pem];
    [self continueConfirm:[web stringByEvaluatingJavaScriptFromString:code]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];

    NSString *contents = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"form-template" ofType:@"html"]] encoding:NSStringEncodingConversionExternalRepresentation];
    web.delegate = self;
    // TODO: store slide.js locally and make it a CocoaPods dependency
    [web loadHTMLString:[TemplateLoader loadTemplate:contents withVariables:@{}] baseURL:[NSURL URLWithString:@"http://slide-dev.ngrok.com"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
