//
//  Header.h
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldsDataStore : NSObject

- (void)redactValue: (NSString *)value forField:(NSDictionary *)field;
- (NSArray *)getRegisteredUsers;
- (NSArray *)getUserForms: (NSString *)user;
- (void)registerUserForm: (NSDictionary *)form forUser: (NSString *)user withPatch: (NSDictionary *)patch;
- (NSArray *)getField: (NSString *)key withConstraints: (NSArray *)constraints;
- (NSArray *)getKVs;
- (NSArray *)getMergedKVs;
- (NSArray *)getForms;
- (NSArray *)getFieldsForForm: (NSDictionary *)form;
+ (id)sharedInstance;
- (NSArray *)getRequests;
- (void)insertRequest: (NSDictionary *)request;

@end
