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
- (void)getForm: (NSString *)formId onSuccess: (void (^)(AFHTTPRequestOperation *, id))success onFailure: (void (^)(AFHTTPRequestOperation *, id))failure;
- (void)postForm: (NSString *)formId withValues: (NSDictionary *)values onSuccess: (void (^)(AFHTTPRequestOperation *, id))success onFailure: (void (^)(AFHTTPRequestOperation *, id))failure;
+ (id)sharedInstance;
@end
