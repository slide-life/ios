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
#import "JSON.h"

@implementation RequestViewController

- (NSArray *)uniqueLiteralValues: (NSArray *)values {
    NSSet *uniq = [NSSet setWithArray:values];
    NSMutableArray *output = [[NSMutableArray alloc] initWithCapacity:values.count];
    for(NSString *elm in uniq) {
        NSString *wrapped = [NSString stringWithFormat:@"\"%@\"", elm];
        if( ![elm isEqualToString:@""] ) {
            [output addObject:wrapped];
        }
    }
    return output;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:self.blocks.count];
    for( NSString *block in self.blocks ) {
        [[FieldsDataStore sharedInstance] valuesForBlock:block withCallback:^(NSArray *values) {
           [fields addObject:[NSString stringWithFormat:@"Forms.selectField('%@', [%@], true)", block, [[self uniqueLiteralValues:values] componentsJoinedByString:@", "]]];
            if( fields.count == self.blocks.count ) {
                NSString *fieldList = [NSString stringWithFormat:@"Forms.populateForm([%@])", [fields componentsJoinedByString:@", "]];
                [web stringByEvaluatingJavaScriptFromString:fieldList];
            }
        }];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)publishResponse: (NSDictionary *)encryptedResponse withPatch: (NSDictionary *)patch {
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] initWithCapacity:encryptedResponse.count + 1];
    for (NSString *block in encryptedResponse) {
        payload[block] = encryptedResponse[block];
    }
    [[Crypto sharedInstance] encrypt:patch withKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"key"] andCallback:^(NSString *encryptedPatch) {
        payload[@"patch"] = [JSON deserializeObject:encryptedPatch][@"fields"];
        [[API sharedInstance] postPayload:payload forConversation:self.conversationId onSuccess:^(id resp) {
            // TODO: handle response
        } onFailure:^(NSURLResponse *resp) {
        }];
    }];
}

- (void)confirm {
    NSString *responseJSON = [web stringByEvaluatingJavaScriptFromString:@"Forms.serializeForm();"];
    NSDictionary *responses = [JSON deserializeObject:responseJSON];
    // TODO: form history should be saved.
    [[Crypto sharedInstance] decryptSymmetricKey:self.pubKey withCallback:^(NSString *key) {
        [[Crypto sharedInstance] encrypt:responses withKey:key andCallback:^(NSString *encryptedJSON) {
            NSDictionary *payload = [JSON deserializeObject:encryptedJSON];
            [self publishResponse:payload withPatch:responses];
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
