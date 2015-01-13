//
//  FieldsDataStore.m
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "FieldsDataStore.h"
#import "API.h"
#import "Crypto.h"

@implementation FieldsDataStore

- (void)decodeField: (NSDictionary *)field withCallback: (void (^)(NSString *))cb {
    [[Crypto sharedInstance] decryptSymmetricKey:field[@"key"] withCallback:^(NSString *key) {
        [[Crypto sharedInstance] decryptPackedString:field[@"value"] withKey:key andCallback:^(NSString *field) {
            cb(field);
        }];
    }];
}

- (void)decodeFields: (NSArray *)fields withCallback: (void (^)(NSArray *))cb {
    NSMutableArray *decoded = [[NSMutableArray alloc] initWithCapacity:fields.count];
    for (NSDictionary *field in fields) {
        [self decodeField:field withCallback:^(NSString *field) {
            [decoded addObject:field];
            if( decoded.count == fields.count ) {
                cb(decoded);
            }
        }];
    }
}

- (void)valuesForBlock: (NSString *)field withCallback: (void (^)(NSArray *))cb {
    void (^task)() = ^{
        if( self.profile[field] ) {
            [self decodeFields:self.profile[field] withCallback:cb];
        } else {
            cb(@[]);
        }
    };
    [self performJob:@{@"task": task}];
}

- (void)performJob: (NSDictionary *)job {
    if( self.isReady ) {
        void (^task)() = job[@"task"];
        task();
    } else {
        [self.queue addObject:job];
    }
}

- (void)ready {
    self.isReady = YES;
    int index = (int)self.queue.count - 1;
    for (NSDictionary *job in self.queue.reverseObjectEnumerator) {
        [self performJob:job];
        [self.queue removeObjectAtIndex:index];
    }
}

static FieldsDataStore *sharedInstance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    if(!sharedInstance) {
        dispatch_once(&onceToken, ^{
            sharedInstance = [[FieldsDataStore alloc] init];
            sharedInstance.profile = @{};
            sharedInstance.queue = [[NSMutableArray alloc] initWithCapacity:255];
            [[API sharedInstance] getProfileForUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"number"] onSuccess:^(NSDictionary *profile) {
                sharedInstance.profile = profile;
                [sharedInstance ready];
            } onFailure:^(id resp) {
            }];
        });
    }
    return sharedInstance;
}

@end