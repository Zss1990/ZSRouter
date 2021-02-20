//
//  ZSAppDelegate.m
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/20.
//

#import "ZSAppDelegate.h"
#import "ZSModuleManager.h"

@implementation ZSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return [[ZSModuleManager instance] application:application
                                 didFinishLaunchingWithOptions:launchOptions];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //注册远程通知
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[ZSModuleManager instance] application:application
       didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[ZSModuleManager instance] application:application
       didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[ZSModuleManager instance] application:application
                           didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[ZSModuleManager instance] application:application
                            didReceiveLocalNotification:notification];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    return [[ZSModuleManager instance] application:application
                                          continueUserActivity:userActivity
                                            restorationHandler:restorationHandler];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ZSModuleManager instance] applicationDidEnterBackground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[ZSModuleManager instance] applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[ZSModuleManager instance] applicationWillResignActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ZSModuleManager instance] applicationWillTerminate:application];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[ZSModuleManager instance] applicationDidReceiveMemoryWarning:application];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[ZSModuleManager instance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [[ZSModuleManager instance] application:app openURL:url options:options];
    
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler
{
    [[ZSModuleManager instance] application:application
                           performActionForShortcutItem:shortcutItem
                                      completionHandler:completionHandler];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[ZSModuleManager instance] applicationWillEnterForeground:application];
}


@end
