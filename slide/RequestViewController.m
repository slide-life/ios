//
//  RequestViewController.m
//  slide
//
//  Created by Matt Neary on 11/30/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "RequestViewController.h"
#import "FieldsDataStore.h"

@implementation RequestViewController

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSMutableArray *fields = [[NSMutableArray alloc] initWithCapacity:self.blocks.count];
    for( NSString *block in self.blocks ) {
        [fields addObject:[NSString stringWithFormat:@"Forms.selectField('%@', [], true)", block]];
    }
    NSString *fieldList = [NSString stringWithFormat:@"Forms.populateForm([%@])", [fields componentsJoinedByString:@", "]];
    [web stringByEvaluatingJavaScriptFromString:fieldList];
}

- (void)confirm {
    NSError *error;
    NSDictionary *responses = [NSJSONSerialization JSONObjectWithData:[[web stringByEvaluatingJavaScriptFromString:@"Forms.serializeForm()"] dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:nil error:&error];
    [[FieldsDataStore sharedInstance] registerUserForm:@{@"name": @"Unknown"} forUser:@"Unknown" withPatch:responses];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Confirm" style:UIBarButtonItemStylePlain target:self action:@selector(confirm)];

    NSString *contents = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"form-template" ofType:@"html"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *slideForm = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"slide-form" ofType:@"js"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *jquery = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"]] encoding:NSStringEncodingConversionExternalRepresentation];
    NSString *styles = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"styles" ofType:@"css"]] encoding:NSStringEncodingConversionExternalRepresentation];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{slide-form.js}}" withString:slideForm];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{jquery.js}}" withString:jquery];
    contents = [contents stringByReplacingOccurrencesOfString:@"{{styles.css}}" withString:styles];
    web.delegate = self;
    [web loadHTMLString:contents baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
