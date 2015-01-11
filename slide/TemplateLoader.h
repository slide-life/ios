//
//  TemplateLoader.h
//  slide
//
//  Created by Matt Neary on 1/11/15.
//  Copyright (c) 2015 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateLoader : NSObject
+ (NSString *)loadTemplate: (NSString *)tmpl withVariables: (NSDictionary *)variables;
@end
