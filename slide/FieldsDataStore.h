//
//  Header.h
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldsDataStore : NSObject

- (void)setField: (NSString *)value forKey: (NSString *)key;
- (NSString *)getField: (NSString *)key;
- (void)patch: (NSDictionary *)values;
+ (id)sharedInstance;

@end
