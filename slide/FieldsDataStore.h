//
//  Header.h
//  slide
//
//  Created by Matt Neary on 9/14/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FieldsDataStore : NSObject

@property NSDictionary *profile;
@property BOOL isReady;
@property NSMutableArray *queue;
+ (id)sharedInstance;
- (void)valuesForBlock: (NSString *)field withCallback: (void (^)(NSArray *))cb;

@end
