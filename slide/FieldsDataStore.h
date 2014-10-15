//
//  Header.h
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldsDataStore : NSObject

- (void)setField: (NSString *)value forKey: (NSDictionary *)key onForm: (NSDictionary *)form;
- (NSArray *)getField: (NSString *)key;
- (NSArray *)getKVs;
- (NSArray *)getForms;
- (void)patch: (NSDictionary *)values forForm: (NSDictionary *)form;
+ (id)sharedInstance;

@end
