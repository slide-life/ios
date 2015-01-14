//
//  API.m
//  slide
//
//  Created by Matt Neary on 10/15/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "API.h"
#import "Crypto.h"
#import "JSON.h"

@implementation API
static API *sharedInstance;
- (API *)init {
    self = [super init];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.jsonManager = [AFHTTPRequestOperationManager manager];
    self.jsonManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.domain = @"http://slide-dev.ngrok.com";
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
- (void)getProfileForUser: (NSString *)userId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    NSString *path = [NSString stringWithFormat:@"%@/users/%@/profile", self.domain, userId];
    [self.manager GET:path parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *profile) {
        NSMutableDictionary *decoded = [[NSMutableDictionary alloc] initWithCapacity:profile.count];
        for (NSString *key in profile) {
            [[Crypto sharedInstance] decryptPackedString:profile[key] withKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"key"] andCallback:^(NSString *value) {
                decoded[key] = [JSON deserializeArray:value];
                if( decoded.count == profile.count ) {
                    success(decoded);
                }
            }];
        }
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
- (void)postDevice: (NSString *)token forUser: (NSString *)number withKey: (NSString *)key andPublicKey: (NSString *)pKey onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    NSString *path = [NSString stringWithFormat:@"%@/users", self.domain];
    // TODO: encrypt key with public key
    [self.jsonManager POST:path parameters:@{@"device": token, @"user": number, @"public_key": pKey, @"key": key} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
        failure(responseObject);
    }];
}
- (void)postPayload: (NSDictionary *)payload forConversation: (NSString *)conversationId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure {
    NSMutableDictionary *post = payload.mutableCopy;
    NSString *path = [NSString stringWithFormat:@"%@/conversations/%@", self.domain, conversationId];
    [[Crypto sharedInstance] encryptSymmetricKey:payload[@"key"] withCallback:^(NSString *key) {
        post[@"key"] = key;
        [self.jsonManager PUT:path parameters:post success:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, id responseObject) {
            failure(responseObject);
        }];
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
