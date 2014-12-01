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
    self.domain = @"http://api-sandbox.slide.life";
    return self;
}
- (void)getUser: (NSString *)userId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    // TODO: get the organization details of a channel.
    NSString *path = [NSString stringWithFormat:@"%@/users/%@", self.domain, userId];
    [self.manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        failure(responseObject);
    }];
}
- (void)getForm: (NSString *)formId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    // TODO: get the fields requested by a channel.
    NSString *path = [NSString stringWithFormat:@"%@/forms/%@", self.domain, formId];
    [self.manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        failure(responseObject);
    }];
}
- (void)postForm: (NSString *)formId withValues: (NSDictionary *)values onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    // TODO: push to channel instead.
    NSString *path = [NSString stringWithFormat:@"%@/forms/%@/responses", self.domain, formId];
    [self.jsonManager POST:path parameters:values success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        failure(responseObject);
    }];
}
- (void)postDevice: (NSString *)token forUser: (NSString *)number onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    // TODO: push to channel instead.
    NSString *path = [NSString stringWithFormat:@"%@/users", self.domain];
    [self.jsonManager POST:path parameters:@{@"device": token, @"user": number} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        failure(responseObject);
    }];
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
