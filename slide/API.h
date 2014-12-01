//
//  API.h
//  slide
//
//  Created by Matt Neary on 10/15/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface API : NSObject
@property AFHTTPRequestOperationManager *manager;
@property AFHTTPRequestOperationManager *jsonManager;
@property NSString *domain;
- (void)getUser: (NSString *)userId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure;
- (void)getForm: (NSString *)formId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure;
- (void)postForm: (NSString *)formId withValues: (NSDictionary *)values onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure;
- (void)postDevice: (NSString *)token forUser: (NSString *)number onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure;
- (void)postPayload: (NSDictionary *)token forChannel: (NSString *)channelId onSuccess: (void (^)(id))success onFailure: (void (^)(id))failure;
+ (id)sharedInstance;
@end
