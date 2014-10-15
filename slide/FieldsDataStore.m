//
//  FieldsDataStore.m
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "FieldsDataStore.h"

@implementation FieldsDataStore

NSString *const filestore = @"keystore.json";

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

- (void)setField: (NSString *)value forKey: (NSString *)key onForm: (NSString *)form {
    NSError *error;
    NSMutableArray *keystore = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self documentsDirectoryFile:filestore]] options:NSJSONReadingMutableContainers error:&error];
    if (value) {
        [keystore addObject:@{@"key": key, @"value": value, @"form": form}];
        NSData *data = [NSJSONSerialization dataWithJSONObject:keystore options:0 error:&error];
        [data writeToFile:[self documentsDirectoryFile:filestore] atomically:YES];
    }
}

- (NSArray *)getField: (NSString *)key {
    NSError *error;
    NSArray *kvs = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self documentsDirectoryFile:filestore]] options:0 error:&error];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:kvs.count];
    for( NSDictionary *kv in kvs ) {
        if( [kv[@"key"] isEqualToString:key] ) {
            [values addObject:kv[@"value"]];
        }
    }
    return values;
}

- (NSArray *)getKVs {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self documentsDirectoryFile:filestore]] options:0 error:&error];
}

- (void)patch: (NSDictionary *)values forForm: (NSString *)form {
    for( NSString *key in values ) {
        [self setField:values[key] forKey:key onForm:form];
    }
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