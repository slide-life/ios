//
//  AppDelegate.m
//  slide
//
//  Created by Jack Dent on 10/09/2014.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Solid Bar"] forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"Solid Bar"]];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];        
    
    return YES;
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    NSLog(@"%@", devToken);
    // This notification is listened for in RequestsViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceToken" object:nil userInfo:@{@"token": devToken}];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // This notification is listened for in RequestsViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notification" object:nil userInfo:userInfo];
}

@end
