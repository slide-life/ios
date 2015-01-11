//
//  TemplateLoader.m
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "TemplateLoader.h"

@implementation TemplateLoader

NSMutableDictionary *cache;
+ (NSString *)loadTemplate: (NSString *)tmpl withVariables: (NSDictionary *)variables {
    NSNumber *hash = @(tmpl.hash);
    if( cache == nil ) {
        cache = [[NSMutableDictionary alloc] initWithCapacity:255];
    }
    if( variables.count == 0 && cache[hash] != nil ) {
        return cache[hash];
    }
    NSArray *results = [[NSRegularExpression regularExpressionWithPattern:@"\\{\\{[^}]+\\}\\}" options:0 error:nil] matchesInString:tmpl options:kNilOptions range:NSMakeRange(0, tmpl.length)];
    
    for(NSTextCheckingResult *result in results.reverseObjectEnumerator) {
        NSString *pattern = [tmpl substringWithRange:result.range];
        NSString *name = [[pattern substringToIndex:pattern.length-2] substringFromIndex:2];
        NSString *replacement;
        if( [name rangeOfString:@"@"].location == 0 ) {
            NSString *filename = [name substringFromIndex:1];
            replacement = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""]] encoding:NSStringEncodingConversionExternalRepresentation];
        } else {
            replacement = variables[name];
        }
        tmpl = [tmpl stringByReplacingCharactersInRange:result.range withString:replacement];
    }
    cache[hash] = tmpl;
    return tmpl;
}

@end
