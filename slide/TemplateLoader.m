//
//  TemplateLoader.m
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import "TemplateLoader.h"
#import "JSON.h"

@implementation TemplateLoader

NSMutableDictionary *cache;
+ (NSString *)loadTemplate: (NSString *)tmpl withVariables: (NSDictionary *)variables {
    NSNumber *hash = @(tmpl.hash + [JSON serialize:variables].hash);
    if( cache == nil ) {
        cache = [[NSMutableDictionary alloc] initWithCapacity:255];
    }
    NSArray *results = [[NSRegularExpression regularExpressionWithPattern:@"\\{\\{[^}]+\\}\\}" options:0 error:nil] matchesInString:tmpl options:kNilOptions range:NSMakeRange(0, tmpl.length)];
    
    for(NSTextCheckingResult *result in results.reverseObjectEnumerator) {
        NSString *pattern = [tmpl substringWithRange:result.range];
        NSString *name = [[pattern substringToIndex:pattern.length-2] substringFromIndex:2];
        NSString *replacement;
        if( [name rangeOfString:@"@"].location == 0 ) {
            NSString *filename = [name substringFromIndex:1];
            replacement = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@""]] encoding:NSStringEncodingConversionExternalRepresentation];
            replacement = [self loadTemplate:replacement withVariables:variables];
        } else {
            if( variables[name] ) {
                replacement = variables[name];
            } else {
                replacement = pattern;
            }
        }
        tmpl = [tmpl stringByReplacingCharactersInRange:result.range withString:replacement];
    }
    cache[hash] = tmpl;
    return tmpl;
}

@end
