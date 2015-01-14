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
#import "JSON.h"

@implementation FieldsDataStore

- (void)decodeField: (NSString *)field withCallback: (void (^)(NSString *))cb {
    [[Crypto sharedInstance] decryptPackedString:field withKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"key"] andCallback:^(NSString *field) {
        cb(field);
    }];
}

- (void)valuesForBlock: (NSString *)field withCallback: (void (^)(NSArray *))cb {
    void (^task)() = ^{
        if( self.profile[field] ) {
            cb(self.profile[field]);
        } else {
            cb(@[]);
        }
    };
    [self performJob:@{@"task": task}];
}

- (void)preparePatch: (NSDictionary *)patch withCallback: (void (^)(NSDictionary *))cb {
    void (^task)() = ^{
        NSMutableDictionary *fullPatch = [[NSMutableDictionary alloc] initWithCapacity:patch.count];
        for (NSString *block in patch) {
            NSArray *field = self.profile[block] == nil ? @[] : self.profile[block];
            NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:field.count + 1];
            for (NSString *value in field) {
                [values addObject:value];
            }
            [values addObject:patch[block]];
            fullPatch[block] = [JSON serializeArray:values];
        }
        cb(fullPatch);
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