//
//  Header.h
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldsDataStore : NSObject

- (NSArray *)getRegisteredUsers;
- (NSArray *)getUserForms: (NSString *)user;
- (void)registerUserForm: (NSDictionary *)form forUser: (NSString *)user;
- (void)setField: (NSString *)value forKey: (NSDictionary *)key onForm: (NSDictionary *)form;
- (NSArray *)getField: (NSString *)key withConstraints: (NSArray *)constraints;
- (NSArray *)getKVs;
- (NSArray *)getMergedKVs;
- (NSArray *)getForms;
- (void)patch: (NSDictionary *)values forForm: (NSDictionary *)form;
+ (id)sharedInstance;

@end
