//
//  ZSModuleManager.m
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/20.
//

#import "ZSModuleManager.h"
#import "ZSModuleProtocol.h"

@implementation ZSModuleItem
- (instancetype)initWithModule:(id)module priority:(NSInteger)priority sequence:(NSInteger)sequence
{
    if (self = [super init]) {
        self.module = module;
        self.priority = priority;
        self.sequence = sequence;
    }
    
    return self;
}
@end


@interface ZSModuleManager(){
    CFBinaryHeapRef _modules;
}

@property (nonatomic, assign) NSInteger nextSequence;
@property (nonatomic, strong) NSMutableDictionary *moduleCache;
@end

static const void *WTModuleItemPriorityRetain(CFAllocatorRef allocator, const void *ptr) {
    return CFRetain(ptr);
}

static void WTModuleItemPriorityRelease(CFAllocatorRef allocator, const void *ptr) {
    CFRelease(ptr);
}

static CFComparisonResult WTModuleItemPriorityCompare(const void *ptr1, const void *ptr2, void *info)
{
    ZSModuleItem *item1 = (__bridge ZSModuleItem *)ptr1;
    ZSModuleItem *item2 = (__bridge ZSModuleItem *)ptr2;
    
    if (item1.priority < item2.priority) {  // greator first
        return kCFCompareLessThan;
    }
    
    if (item1.priority > item2.priority) {
        return kCFCompareGreaterThan;
    }
    
    if (item1.sequence > item2.sequence) {  // lesser first
        return kCFCompareLessThan;
    }
    
    if (item1.sequence < item2.sequence) {
        return kCFCompareGreaterThan;
    }
    
    return kCFCompareEqualTo;
}
@implementation ZSModuleManager

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        CFBinaryHeapCallBacks callbacks = (CFBinaryHeapCallBacks) {
            .version = 0,
            .retain = &WTModuleItemPriorityRetain,
            .release = &WTModuleItemPriorityRelease,
            .copyDescription = &CFCopyDescription,
            .compare = &WTModuleItemPriorityCompare
        };
        
        _modules = CFBinaryHeapCreate(kCFAllocatorDefault, 0, &callbacks, NULL);
        _moduleCache = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc
{
    if (_modules) {
        CFRelease(_modules);
    }
}

+ (void)registerModuleClass:(Class <ZSModuleProtocol>)moduleClass
                     config:(NSDictionary *)config
                   priority:(NSInteger)priority
{
    id <ZSModuleProtocol> module = [[(Class)moduleClass alloc] initWithConfiguration:config];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[self instance] registerModule:module priority:priority];
#pragma clang diagnostic pop
}

- (void)enumerateModulesUsingBlock:(__attribute__((noescape)) void (^)(id module, BOOL *stop))block
{
    CFIndex count = CFBinaryHeapGetCount(_modules);
    const void **list = calloc(count, sizeof(const void *));
    CFBinaryHeapGetValues(_modules, list);
    
    CFArrayRef objects = CFArrayCreate(kCFAllocatorDefault, list, count, &kCFTypeArrayCallBacks);
    
    NSArray *items = (__bridge_transfer NSArray *)objects;
    
    [items enumerateObjectsWithOptions:NSEnumerationReverse
                            usingBlock:^(ZSModuleItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                block(obj.module, stop);
                            }];
}

- (void)registerModule:(id)module priority:(NSInteger)priority
{
    ZSModuleItem *item = [[ZSModuleItem alloc] initWithModule:module
                                                     priority:priority
                                                     sequence:self.nextSequence];
    
    CFBinaryHeapAddValue(_modules, (__bridge const void *)(item));
    [self.moduleCache setValue:module forKey:NSStringFromClass([module class])];
    self.nextSequence += 1;
}

- (id)moduleInstanceByName:(NSString *)moduleName
{
    return self.moduleCache[moduleName];
}

+ (void)triggerCustomEvent:(SKCustomEventType)eventType params:(NSDictionary *_Nullable)params{
    [[ZSModuleManager instance] enumerateModulesUsingBlock:^(id  _Nonnull module, BOOL * _Nonnull stop) {
        if ([module respondsToSelector:@selector(didReceiveCustomEvent:params:)]) {
            [module didReceiveCustomEvent:eventType params:params];
        }
    }];
}

@end


@implementation ZSModuleManager (AppDelegate)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    SEL sel = _cmd;
    __block BOOL result = NO;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            result = [module application:application didFinishLaunchingWithOptions:launchOptions];
            
            if (!result) {  // stop when got NO
                *stop = YES;
            }
        }
    }];
    
    return result;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationDidBecomeActive:application];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationWillResignActive:application];
        }
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationDidEnterBackground:application];
        }
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationWillEnterForeground:application];
        }
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    SEL sel = _cmd;
    __block BOOL result = NO;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            result = [module application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
            
            if (result) {   // stop if handled
                *stop = YES;
            }
        }
    }];
    
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    SEL sel = _cmd;
    __block BOOL result = NO;
    
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            result = [module application:app openURL:url options:options];
            
            if (result) {   // stop if handled
                *stop = YES;
            }
        }
    }];
    
    return result;
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationDidReceiveMemoryWarning:application];
        }
    }];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationSignificantTimeChange:application];
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application didReceiveLocalNotification:notification];
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application didReceiveRemoteNotification:userInfo];
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
        }
    }];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    SEL sel = _cmd;
    __block BOOL result = NO;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            result = [module application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
            if (result) { // stop if handled
                *stop = YES;
            }
        }
    }];
    
    return result;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module applicationWillTerminate:application];
        }
    }];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application performFetchWithCompletionHandler:completionHandler];
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    SEL sel = _cmd;
    [self enumerateModulesUsingBlock:^(id module, BOOL *stop) {
        if ([module respondsToSelector:sel]) {
            [module application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }];
}
@end
