//
//  ZSRBModule.m
//  ZSRouter_Example
//
//  Created by shuaishuai on 2021/2/20.
//  Copyright © 2021 zhushuaishuai. All rights reserved.
//

#import "ZSRBModule.h"

@implementation ZSRBModule

+ (void)load
{
    [ZSModuleManager registerModuleClass:self config:@{
                                                         } priority:100];
    
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration
{
    if (self = [super init]) {
        
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"--->:%s",__func__);

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"--->:%s",__func__);

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"--->:%s",__func__);

}
@end
