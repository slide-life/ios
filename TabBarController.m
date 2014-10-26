//
//  TabBarController.m
//  slide
//
//  Created by Matt Neary on 10/25/14.
//  Copyright (c) 2014 slide. All rights reserved.
//

#import "TabBarController.h"

@implementation TabBarController
- (void)viewDidLoad {
    for (UITabBarItem *item in self.tabBar.items){
        [item setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    }
}
@end
