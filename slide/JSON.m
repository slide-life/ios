//
//  JSON.m
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "JSON.h"

@implementation JSON

+ (NSString *)serialize: (NSDictionary *)dictionary {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionExternalRepresentation];
}
+ (NSString *)serializeArray: (NSArray *)array {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionExternalRepresentation];
}
+ (NSDictionary *)deserializeObject: (NSString *)data {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:0 error:&error];
}
+ (NSArray *)deserializeArray: (NSString *)data {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSStringEncodingConversionExternalRepresentation] options:0 error:&error];
}

@end
