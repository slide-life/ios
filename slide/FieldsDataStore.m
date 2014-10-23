//
//  FieldsDataStore.m
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "FieldsDataStore.h"
#import "API.h"

@implementation FieldsDataStore

NSString *const filestore = @"keystore.json";
NSString *const userstore = @"userstore.json";

- (NSString *)documentsDirectoryFile: (NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *file = [basePath stringByAppendingPathComponent:fileName];
    if( ![[NSFileManager defaultManager] fileExistsAtPath:file] ) {
        NSData *dataBuffer = [@"[]" dataUsingEncoding:NSStringEncodingConversionExternalRepresentation];
        [[NSFileManager defaultManager] createFileAtPath:file contents:dataBuffer attributes:nil];
    }
    return file;
}

- (void)addForm: (NSDictionary *)form forUser: (NSDictionary *)user {
    NSError *error;
    NSMutableArray *keystore = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self documentsDirectoryFile:userstore]] options:NSJSONReadingMutableContainers error:&error];
    [keystore addObject:@{@"user": user, @"form": form}];
    NSData *data = [NSJSONSerialization dataWithJSONObject:keystore options:0 error:&error];
    [data writeToFile:[self documentsDirectoryFile:userstore] atomically:YES];
}

- (void)registerUserForm: (NSDictionary *)form forUser: (NSString *)user {
    NSLog(@"registering: %@ %@", form, user);
    [[API sharedInstance] getUser:user onSuccess:^(NSDictionary *user) {
        // TODO: save user details with a link to the form in a new table
        [self addForm:form forUser:user];
    } onFailure:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSArray *)getUserForms {
    NSError *error;
    NSMutableArray *keystore = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self documentsDirectoryFile:userstore]] options:NSJSONReadingMutableContainers error:&error];
    return keystore;
}

- (NSArray *)getUserForms: (NSString *)user {
    NSArray *allForms = [self getUserForms];
    NSMutableArray *userForms = [[NSMutableArray alloc] initWithCapacity:allForms.count];
    for( NSDictionary *userForm in allForms ) {
        if( [userForm[@"user"][@"id"] isEqualToString:user] ) {
            [userForms addObject:userForm];
        }
    }
    return userForms;
}

- (NSArray *)getRegisteredUserIds {
    NSArray *userForms = [self getUserForms];
    NSMutableDictionary *users = [[NSMutableDictionary alloc] initWithCapacity:userForms.count];
    for( NSDictionary *userForm in userForms ) {
        users[userForm[@"user"][@"id"]] = @YES;
    }
    return users.allKeys;
}

- (NSDictionary *)getUserInfo: (NSString *)user {
    NSArray *userForms = [self getUserForms];
    NSMutableDictionary *userInfo;
    NSNumber *formCount = @0;
    for( NSDictionary *userForm in userForms ) {
        if( [userForm[@"user"][@"id"] isEqualToString:user] ) {
            userInfo = userForm[@"user"];
            formCount = [NSNumber numberWithInt:formCount.intValue + 1];
        }
    }
    userInfo[@"formCount"] = formCount;
    return userInfo;
}

- (NSArray *)getRegisteredUsers {
    NSArray *userIds = [self getRegisteredUserIds];
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:userIds.count];
    for( NSString *userId in userIds ) {
        [users addObject:[self getUserInfo:userId]];
    }
    return users;
}

- (void)setField: (NSString *)value forKey: (NSDictionary *)key onForm: (NSDictionary *)form {
    NSMutableArray *keystore = [NSMutableArray arrayWithArray:[self getKVs]];
    if (value) {
        NSMutableDictionary *formDetails = [NSMutableDictionary dictionaryWithDictionary:@{@"name": form[@"name"], @"user": form[@"user"]}];        
        [keystore addObject:@{@"key": key[@"id"], @"value": value, @"form": formDetails, @"field": key}];
        [self saveKVs:keystore];
    }
}

- (NSArray *)getField: (NSString *)key withConstraints: (NSArray *)constraints {
    NSArray *kvs = [self getKVs];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:kvs.count];
    for( NSDictionary *kv in kvs ) {
        if( [kv[@"key"] isEqualToString:key] && ![kv[@"value"] isEqual:@"[*redacted*]"] ) {
            [values addObject:kv[@"value"]];
        }
    }
    return values;
}

- (NSArray *)getKVs {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self documentsDirectoryFile:filestore]] options:NSJSONReadingMutableContainers error:&error];
}

- (void)saveKVs: (NSArray *)kvs toFile: (NSString *)file {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:kvs options:0 error:&error];
    [data writeToFile:[self documentsDirectoryFile:filestore] atomically:YES];
}

- (void)saveKVs: (NSArray *)kvs {
    [self saveKVs:kvs toFile:[self documentsDirectoryFile:filestore]];
}

- (NSArray *)getMergedKVs {
    NSArray *kvs = [self getKVs];
    NSMutableDictionary *merged = [[NSMutableDictionary alloc] initWithCapacity:kvs.count];
    for( NSDictionary *kv in kvs ) {
        if( ![kv[@"value"] isEqual:@"[*redacted*]"] ) {
            merged[kv[@"key"]] = merged[kv[@"key"]] == nil ? @{@"values": [[NSMutableArray alloc] initWithCapacity:kvs.count], @"field": kv[@"field"]} : merged[kv[@"key"]];
            [merged[kv[@"key"]][@"values"] addObject:kv[@"value"]];
        }
    }
    NSMutableArray *flat = [[NSMutableArray alloc] initWithCapacity:kvs.count];
    for( NSString *key in merged.allKeys ) {
        [flat addObject:@{@"key": key, @"values": merged[key][@"values"], @"field": merged[key][@"field"]}];
    }
    return flat;
}

- (NSArray *)getForms {
    NSArray *kvs = [self getKVs];
    NSMutableDictionary *hash = [[NSMutableDictionary alloc] initWithCapacity:kvs.count];
    for( NSDictionary *kv in kvs ) {
        if( hash[kv[@"form"]] == nil ) {
            hash[kv[@"form"]] = @0;
        }
        hash[kv[@"form"]] = [NSNumber numberWithInt:((NSNumber *)hash[kv[@"form"]]).intValue + 1];
    }
    NSMutableArray *orgs = [[NSMutableArray alloc] initWithCapacity:255];
    for( NSString *form in hash.allKeys ) {
        [orgs addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"form": form, @"count": hash[form]}]];
    }
    return orgs;
}

- (void)patch: (NSDictionary *)values forForm: (NSDictionary *)form {
    for( NSDictionary *key in values ) {
        [self setField:values[key] forKey:key onForm:form];
    }
}

- (void)redactValue: (NSString *)value forField:(NSDictionary *)field {
    NSArray *kvs = [self getKVs];;
    for( NSMutableDictionary *kv in kvs ) {
        if( [kv[@"field"][@"id"] isEqualToString:field[@"id"]] &&
            [kv[@"field"][@"name"] isEqualToString:field[@"name"]] &&
            [kv[@"value"] isEqual:value]) {
            kv[@"value"] = @"[*redacted*]";
        }
    }
    [self saveKVs:kvs];
}

static FieldsDataStore *sharedInstance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    if(!sharedInstance) {
        dispatch_once(&onceToken, ^{
           sharedInstance = [[FieldsDataStore alloc] init];
        });
    }
    return sharedInstance;
}

@end