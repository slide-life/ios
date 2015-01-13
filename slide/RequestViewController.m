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
#import "Crypto.h"

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

- (void)confirm {
    NSError *error;
    NSDictionary *responses = [NSJSONSerialization JSONObjectWithData:[[web stringByEvaluatingJavaScriptFromString:@"Forms.serializeForm()"] dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:NSJSONReadingAllowFragments error:&error];
    // TODO: form history should be saved.
    [[Crypto sharedInstance] decryptSymmetricKey:self.pubKey withCallback:^(NSString *key) {
        [[Crypto sharedInstance] encrypt:responses withKey:key andCallback:^(NSString *encryptedJSON) {
            NSError *error;
            NSData *data = [encryptedJSON dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            [[API sharedInstance] postPayload:payload forConversation:self.conversationId onSuccess:^(id resp) {
                // TODO: handle response
            } onFailure:^(NSURLResponse *resp) {
            }];
        }];
    }];
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
}

@end
