//
//  API.m
//  slide
//
//  Created by Matt Neary on 10/15/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "API.h"

@implementation API
static API *sharedInstance;
- (API *)init {
    self = [super init];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.jsonManager = [AFHTTPRequestOperationManager manager];
    self.jsonManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.domain = @"https://slide-dev.ngrok.com";
    return self;
}
- (void)getForm: (NSString *)formId onSuccess: (void (^)(AFHTTPRequestOperation *, id))success onFailure: (void (^)(AFHTTPRequestOperation *, id))failure {
    NSString *path = [NSString stringWithFormat:@"%@/forms/%@", self.domain, formId];
    [self.manager GET:path parameters:nil success:success failure:failure];
}
- (void)postForm: (NSString *)formId withValues: (NSDictionary *)values onSuccess: (void (^)(AFHTTPRequestOperation *, id))success onFailure: (void (^)(AFHTTPRequestOperation *, id))failure {
    NSString *path = [NSString stringWithFormat:@"%@/forms/%@/responses", self.domain, formId];
    [self.jsonManager POST:path parameters:values success:success failure:failure];
}
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    if(!sharedInstance) {
        dispatch_once(&onceToken, ^{
            sharedInstance = [[API alloc] init];
        });
    }
    return sharedInstance;
}
@end
