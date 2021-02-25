//
//  ZSModuleProtocol.h
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/20.
//

#import <Foundation/Foundation.h>
#import <ZSRouter/ZSModuleManager.h>

typedef NS_ENUM(NSInteger, SKCustomEventType)
{
    // 用户事件
    SKLoginEvent = 0,       // 登入
    SKLogoutEvent,          // 登出
    // UI事件
    SKEnterHomePageEvent,   // 进入首页
    // 司机事件
    SKStartWorkingEvent,    // 出车
    SKStartServiceEvent,    // 服务中
    SKEndWorkingEvent,      // 收车
    // 订单事件
    SKOrderStartEvent,      // 去接乘客
    SKCarWaitingEvent,      // 等待乘客
    SKTripStartEvent,       // 去送乘客
    SKPaySendEvent,         // 确认金额
    SKTripEndEvent,         // 结束行程
    SKOrderCancelledEvent,  // 订单取消
};

NS_ASSUME_NONNULL_BEGIN

@protocol ZSModuleProtocol <NSObject>

- (instancetype)initWithConfiguration:(NSDictionary *)configuration;

@optional

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)applicationDidBecomeActive:(UIApplication *)application;

- (void)applicationWillResignActive:(UIApplication *)application;

- (void)applicationDidEnterBackground:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

- (void)applicationWillEnterForeground:(UIApplication *)application;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void)applicationSignificantTimeChange:(UIApplication *)application;

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler;

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler;

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

- (void)didReceiveCustomEvent:(SKCustomEventType)eventType params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
