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
@end
