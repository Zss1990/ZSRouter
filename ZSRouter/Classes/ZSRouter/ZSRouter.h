//
//  ZSRouter.h
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/6.
// FFRouter

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZSRouterHandler)(NSDictionary <NSString *, id> * _Nullable routerParameters);
typedef id _Nullable (^ZSObjectRouterHandler)(NSDictionary <NSString *, id> * _Nullable routerParameters);
typedef void (^ZSRouterCallback)(id _Nullable callbackObjc);
typedef void (^ZSCallbackRouterHandler)(NSDictionary <NSString *, id> * _Nullable routerParameters, ZSRouterCallback _Nullable targetCallback);
typedef void (^ZSUnregisterRouterHandler)(NSString * _Nullable routerURL);
typedef void (^ZSRouterUnregisterURLHandler)(NSString * _Nullable route, NSDictionary<NSString *, id> * _Nullable parameters);


@interface ZSRouter : NSObject

#pragma mark - Create objects based on Scheme

/// Returns the global routing scheme
+ (instancetype)globalRouter;

/// Returns a routing namespace for the given scheme
+ (instancetype)routerForScheme:(NSString *)scheme;

/// Unregister and delete an entire scheme namespace
+ (void)unRouterScheme:(NSString *)scheme;

/// Unregister all routes
+ (void)unAllRouterSchemes;

/// Return all registered routes in the receiving scheme.
/// @see allRoutes
//- (NSArray <JLRRouteDefinition *> *)routes;
/// Return all registered routes across all schemes, keyed by scheme
/// @see routes
//+ (NSDictionary <NSString *, NSArray <JLRRouteDefinition *> *> *)allRoutes;

#pragma mark - Log
/**
 Whether to display Log for debugging
 
 @param enable YES or NO.The default is NO
 */
+ (void)setLogEnabled:(BOOL)enable;


#pragma mark - Registered Route

/**
 Registers a routePattern  in the receiving scheme.
 
 @param routePattern Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @param handlerBlock Callback after route
 */
- (void)addRoute:(NSString *)routePattern handler:(ZSRouterHandler)handlerBlock;

/**
 Registers a routePattern  in the receiving scheme.,use it with 'routeObjectURL:' and ‘routeObjectURL: withParameters:’,can return a Object.
 
 @param routePattern  Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @param handlerBlock Callback after route, and you can get a Object in this callback.
 */
- (void)addObjectRoute:(NSString *)routePattern handler:(ZSObjectRouterHandler)handlerBlock;

/**
 Registered URL, use it with `routeCallbackURL: targetCallback:'and `routeCallback URL: withParameters: targetCallback:', calls back `targetCallback' asynchronously to return an Object
 
 @param routePattern Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @param handlerBlock Callback after route,There is a `targetCallback' in `handlerBlock', which corresponds to the `targetCallback:' in `routeCallbackURL: targetCallback:'and `routeCallbackURL: withParameters: targetCallback:', which can be used for asynchronous callback to return an Object.
 */
- (void)addCallbackRoute:(NSString *)routePattern handler:(ZSCallbackRouterHandler)handlerBlock;


#pragma mark - Open Route
/**
 Determine whether URL can be Route (whether it has been registered).
 
 @param routePattern Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @return Can it be routed
 */
- (BOOL)canRouteURL:(NSString *)routePattern;
+ (BOOL)canRoute:(NSString *)Route;


#pragma mark - Exe Route
/**
 Route a Route
 
 @param route URL to be routed
 */
+ (BOOL)exeRoute:(NSString *)route;

/**
 Route a URL and bring additional parameters.
 
 @param route URL to be routed
 @param parameters Additional parameters
 */
+ (BOOL)exeRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters;

/**
 Route a URL and get the returned Object
 
 @param route URL to be routed
 @return Returned Object
 */
+ (id _Nullable )exeObjectRoute:(NSString *_Nullable)route;

/**
 Route a URL and bring additional parameters. get the returned Object
 
 @param route URL to be routed
 @param parameters Additional parameters
 @return Returned Object
 */
+ (id _Nullable )exeObjectRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters;

/**
 Route a URL, 'targetCallBack' can asynchronously callback to return a Object.
 
 @param route URL to be routed
 @param targetCallback asynchronous callback
 */
+ (BOOL)exeCallbackRoute:(NSString *)route targetCallback:(ZSRouterCallback _Nullable )targetCallback;

/**
 Route a URL with additional parameters, and 'targetCallBack' can asynchronously callback to return a Object.
 
 @param route URL to be routed
 @param parameters Additional parameters
 @param targetCallback asynchronous callback
 */
+ (BOOL)exeCallbackRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters targetCallback:(ZSRouterCallback _Nullable)targetCallback;


#pragma mark - Monitor
/**
 Route callback for an unregistered URL
 
 @param handler Callback
 */
- (void)monitorExeUnregisterRouteHandler:(ZSRouterUnregisterURLHandler _Nullable)handler;


//
//#pragma mark - 类别名
//
///// 将 ”类名别称“ 与 类名绑定 （未绑定的clsQuick默认为原始类名）
///// @param clsQuick  类名别称
///// @param clsName 类名
//- (BOOL)bingCls:(NSString *)clsQuick clsName:(NSString *)clsName;
//
///*
// scheme://host:path?p1Key=p1Value?p2Key=p2Value?p3Key=p3Value
//
// myApp://clsA/getID     parameters
// myApp://clsA/getID?p1Key=p1Value?p2Key=p2Value     parameters
// 1. 映射到某个类的某个方法
// scheme     --->    scheme      --->    module
// host       --->    clsQuick    --->    class
// path       --->    action      --->    method
// parameters --->    parameters  --->    parameters
//
// parameters:可以为iOS系统中自带对象，在routerPattern 中携带的参数会拼接到parameters上
// */
//
//#pragma mark - 注册
//- (void)addRoute:(NSString *)routerPattern priority:(NSUInteger)priority handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> *parameters))handlerBlock;
//
//#pragma mark - 移除
///// Removes the first route matching routePattern from the receiving scheme.
//- (void)removeRouteWithPattern:(NSString *)routePattern;
//
///// Removes all routes from the receiving scheme.
//- (void)removeAllRoutes;
//
//#pragma mark - 查看
///// Return all registered routes in the receiving scheme.
///// @see allRoutes
////- (NSArray <JLRRouteDefinition *> *)routes;
//
///// Return all registered routes across all schemes, keyed by scheme
///// @see routes
////+ (NSDictionary <NSString *, NSArray <JLRRouteDefinition *> *> *)allRoutes;
//
//#pragma mark - 全局监听
///// Registers a routePattern with default priority (0) using dictionary-style subscripting.
//- (void)setObject:(nullable id)handlerBlock forKeyedSubscript:(NSString *)routePatten;
//
//#pragma mark - 获取
///// Returns YES if the provided URL will successfully match against any registered route, NO if not.
//+ (BOOL)canRouteURL:(nullable NSURL *)URL;
//
///// Returns YES if the provided URL will successfully match against any registered route for the current scheme, NO if not.
//- (BOOL)canRouteURL:(nullable NSURL *)URL;
//
///// Routes a URL in any routes scheme, calling handler blocks (for patterns that match URL) until one returns YES.
///// Additional parameters get passed through to the matched route block.
//+ (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters;
//
///// Routes a URL in a specific scheme, calling handler blocks (for patterns that match URL) until one returns YES.
///// Additional parameters get passed through to the matched route block.
//- (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters;
//
//
///// 根据URL获取一个对象
///// @param URL URL格式的字符串
///// @param userInfo 参数
//- (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo;
///// 根据URL获取一个对象
///// @param URL URL格式的字符串
///// @param userInfo 参数
//+ (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo;
//

@end

@interface ZSRouter (Util)
/// 尝试push，如果objVC是一个UIViewController,则进行push；如果不是返回NO
/// @param objVC 疑是UIViewController对象
+ (BOOL)tryPushVC:(id)objVC;

@end

#define ZSAppScheme  [ZSRouter appScheme]
#define ZSAppRoute(routePattern) [ZSRouter appSchemeRoute:routePattern]

//在mainbundle的Info.plist中配置默认“app_router_scheme”
static  NSString *const app_router_scheme = @"app_router_scheme";

// 使用默认的Scheme，不需要添加额外的Scheme
@interface ZSRouter (AppScheme)

/// 快速获取APP的scheme值；会从mainbundle的Info.plist中获取“app_router_scheme”配置的值；
+ (NSString *)appScheme;

/// 快速获取APP的scheme值,并根据routePattern拼接为route地址
/// @param routePattern routePattern
+ (NSString *)appSchemeRoute:(NSString *)routePattern;

// 注册
+ (void)addAppSchemeRoute:(NSString *)routePattern handler:(ZSRouterHandler)handlerBlock;
+ (void)addAppSchemeObjectRoute:(NSString *)routePattern handler:(ZSObjectRouterHandler)handlerBlock;
+ (void)addAppSchemeCallbackRoute:(NSString *)routePattern handler:(ZSCallbackRouterHandler)handlerBlock;
// 执行
+ (BOOL)exeAppSchemeRoute:(NSString *)route;
+ (BOOL)exeAppSchemeRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters;
+ (id _Nullable )exeAppSchemeObjectRoute:(NSString *_Nullable)route;
+ (id _Nullable )exeAppSchemeObjectRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters;
+ (BOOL)exeAppSchemeCallbackRoute:(NSString *)route targetCallback:(ZSRouterCallback _Nullable )targetCallback;
+ (BOOL)exeAppSchemeCallbackRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters targetCallback:(ZSRouterCallback _Nullable)targetCallback;

@end

NS_ASSUME_NONNULL_END
