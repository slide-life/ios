//
//  JSON.h
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSON : NSObject
+ (NSString *)serialize: (NSDictionary *)dictionary;
+ (NSDictionary *)deserializeObject: (NSString *)data;
@end
