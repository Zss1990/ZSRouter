//
//  ZSRouter.m
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/6.
//

#import "ZSRouter.h"
#import "ZSRouterRewrite.h"
#import "ZSRouterLogger.h"
#import "ZSRouterNavigation.h"

static NSString *const ZSRouterWildcard = @"*";
static NSString *ZSSpecialCharacters = @"/?&.";
static NSString *const ZSRouterCoreKey = @"ZSRouterCore";
static NSString *const ZSRouterCoreBlockKey = @"ZSRouterCoreBlock";
static NSString *const ZSRouterCoreTypeKey = @"ZSRouterCoreType";
NSString *const ZSRouterParameterURLKey = @"ZSRouterParameterURL";
NSString *const ZSRouterGlobalRouterScheme = @"ZSRouterGlobalRouterScheme";
static NSMutableDictionary *ZSRGlobal_routerControllersMap = nil;

typedef NS_ENUM(NSInteger,ZSRouterType) {
    ZSRouterTypeDefault = 0,
    ZSRouterTypeObject = 1,
    ZSRouterTypeCallback = 2,
};



@interface ZSRouter ()

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic,strong) NSMutableDictionary *routes;
@property (nonatomic,strong) ZSRouterUnregisterURLHandler routerUnregisterURLHandler;

@end

@implementation ZSRouter

+ (void)initialize
{
    if (self == [ZSRouter class]) {
        // Set default global options
//        JLRGlobal_verboseLoggingEnabled = NO;
//        JLRGlobal_shouldDecodePlusSymbols = YES;
//        JLRGlobal_alwaysTreatsHostAsPathComponent = NO;
//        JLRGlobal_routeDefinitionClass = [JLRRouteDefinition class];
    }
}

- (instancetype)init
{
    if ((self = [super init])) {
//        self.mutableRoutes = [NSMutableArray array];
    }
    return self;
}
//- (NSString *)description
//{
//    return [self.mutableRoutes description];
//}



#pragma mark - Create objects based on Scheme

/// Returns the global routing scheme
+ (instancetype)globalRouter
{
    return [self routerForScheme:ZSRouterGlobalRouterScheme];
}

/// Returns a routing namespace for the given scheme
+ (instancetype)routerForScheme:(NSString *)scheme
{
    if (!scheme) {
        return nil;
    }
    ZSRouter *routerController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZSRGlobal_routerControllersMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!ZSRGlobal_routerControllersMap[scheme]) {
        routerController = [[self alloc] init];
        routerController.scheme = scheme;
        ZSRGlobal_routerControllersMap[scheme] = routerController;
    }
    routerController = ZSRGlobal_routerControllersMap[scheme];
    return routerController;
}

/// Unregister and delete an entire scheme namespace
+ (void)unRouterScheme:(NSString *)scheme
{
    [ZSRGlobal_routerControllersMap removeObjectForKey:scheme];
}

/// Unregister all routes
+ (void)unAllRouterSchemes
{
    [ZSRGlobal_routerControllersMap removeAllObjects];
}
#pragma mark - Log
/**
 Whether to display Log for debugging
 
 @param enable YES or NO.The default is NO
 */
+ (void)setLogEnabled:(BOOL)enable
{
    [ZSRouterLogger enableLog:enable];
}

#pragma mark - Registered Route

/**
 Registers a routePattern  in the receiving scheme.
 
 @param routePattern Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @param handlerBlock Callback after route
 */
- (void)addRoute:(NSString *)routePattern handler:(ZSRouterHandler)handlerBlock
{
    [self registerRouteURL:[self getRouteURL:routePattern] handler:handlerBlock];
}

/**
 Registers a routePattern  in the receiving scheme.,use it with 'routeObjectURL:' and ‘routeObjectURL: withParameters:’,can return a Object.
 
 @param routePattern  Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @param handlerBlock Callback after route, and you can get a Object in this callback.
 */
- (void)addObjectRoute:(NSString *)routePattern handler:(ZSObjectRouterHandler)handlerBlock
{
    [self registerObjectRouteURL:[self getRouteURL:routePattern] handler:handlerBlock];
}

/**
 Registered URL, use it with `routeCallbackURL: targetCallback:'and `routeCallback URL: withParameters: targetCallback:', calls back `targetCallback' asynchronously to return an Object
 
 @param routePattern Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @param handlerBlock Callback after route,There is a `targetCallback' in `handlerBlock', which corresponds to the `targetCallback:' in `routeCallbackURL: targetCallback:'and `routeCallbackURL: withParameters: targetCallback:', which can be used for asynchronous callback to return an Object.
 */
- (void)addCallbackRoute:(NSString *)routePattern handler:(ZSCallbackRouterHandler)handlerBlock
{
    [self registerCallbackRouteURL:[self getRouteURL:routePattern] handler:handlerBlock];
}

#pragma mark - Monitor
/**
 Route callback for an unregistered URL
 
 @param handler Callback
 */
- (void)monitorExeUnregisterRouteHandler:(ZSRouterUnregisterURLHandler)handler
{
    [self setRouterUnregisterURLHandler:handler];
}


#pragma mark - Open Route
/**
 Determine whether URL can be Route (whether it has been registered).
 
 @param routePattern Registers a routePattern （host/path1/path1?key1=value1?key2=value2）
 @return Can it be routed
 */
- (BOOL)canRouteURL:(NSString *)routePattern
{
    return YES;
}
+ (BOOL)canRoute:(NSString *)Route
{
    return YES;
}


#pragma mark - Exe Route
/**
 Route a Route
 
 @param route URL to be routed
 */
+ (BOOL)exeRoute:(NSString *)route
{
    return [self exeRoute:route withParameters:nil];
}

/**
 Route a URL and bring additional parameters.
 
 @param route URL to be routed
 @param parameters Additional parameters
 */
+ (BOOL)exeRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *)parameters
{
//    FFRouterLog(@"Route to URL:%@\nwithParameters:%@",URL,parameters);
    NSString *rewriteURL = [ZSRouterRewrite rewriteURL:route];
    route = [rewriteURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    ZSRouter *router = [self _routesControllerForRoute:route];
    NSMutableDictionary *routerParameters = [router achieveParametersFromURL:route];
    if(!routerParameters){
       ZSRouterErrorLog(@"Route unregistered route:%@",route);
        [router unregisterURLBeRouterWithRoute:route withParameters:parameters];
        return NO;
    }
    
    [routerParameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            routerParameters[key] = [NSString stringWithFormat:@"%@",obj];
        }
    }];
    
    if (routerParameters) {
        NSDictionary *coreDic = routerParameters[ZSRouterCoreKey];
        ZSRouterHandler handler = coreDic[ZSRouterCoreBlockKey];
        ZSRouterType type = [coreDic[ZSRouterCoreTypeKey] integerValue];
        if (type != ZSRouterTypeDefault) {
            [self routeTypeCheckLogWithCorrectType:type url:route];
            return NO;
        }
        if (handler) {
            if (parameters) {
                [routerParameters addEntriesFromDictionary:parameters];
            }
            [routerParameters removeObjectForKey:ZSRouterCoreKey];
            handler(routerParameters);
        }
    }
    return YES;
}

/**
 Route a URL and get the returned Object
 
 @param route URL to be routed
 @return Returned Object
 */
+ (id)exeObjectRoute:(NSString *)route
{
    return [self exeObjectRoute:route withParameters:nil];
}

/**
 Route a URL and bring additional parameters. get the returned Object
 
 @param route URL to be routed
 @param parameters Additional parameters
 @return Returned Object
 */
+ (id)exeObjectRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *)parameters
{
//    FFRouterLog(@"Route to ObjectURL:%@\nwithParameters:%@",URL,parameters);
    NSString *rewriteURL = [ZSRouterRewrite rewriteURL:route];
    route = [rewriteURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    ZSRouter *router = [self _routesControllerForRoute:route];
    NSMutableDictionary *routerParameters = [router achieveParametersFromURL:route];
    if(!routerParameters){
       ZSRouterErrorLog(@"Route unregistered ObjectURL:%@",route);
        [router unregisterURLBeRouterWithRoute:route withParameters:parameters];
        return nil;
    }
    [routerParameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            routerParameters[key] = [NSString stringWithFormat:@"%@",obj];
        }
    }];
    NSDictionary *coreDic = routerParameters[ZSRouterCoreKey];
    ZSObjectRouterHandler handler = coreDic[ZSRouterCoreBlockKey];
    ZSRouterType type = [coreDic[ZSRouterCoreTypeKey] integerValue];
    if (type != ZSRouterTypeObject) {
        [self routeTypeCheckLogWithCorrectType:type url:route];
        return nil;
    }
    if (handler) {
        if (parameters) {
            [routerParameters addEntriesFromDictionary:parameters];
        }
        [routerParameters removeObjectForKey:ZSRouterCoreKey];
        return handler(routerParameters);
    }
     return nil;
}

/**
 Route a URL, 'targetCallBack' can asynchronously callback to return a Object.
 
 @param route URL to be routed
 @param targetCallback asynchronous callback
 */
+ (BOOL)exeCallbackRoute:(NSString *)route targetCallback:(ZSRouterCallback)targetCallback
{
    return [self exeCallbackRoute:route withParameters:nil targetCallback:targetCallback];
}

/**
 Route a URL with additional parameters, and 'targetCallBack' can asynchronously callback to return a Object.
 
 @param route URL to be routed
 @param parameters Additional parameters
 @param targetCallback asynchronous callback
 */
+ (BOOL)exeCallbackRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *)parameters targetCallback:(ZSRouterCallback)targetCallback
{
//    FFRouterLog(@"Route to URL:%@\nwithParameters:%@",URL,parameters);
    NSString *rewriteURL = [ZSRouterRewrite rewriteURL:route];
    route = [rewriteURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];    ZSRouter *router = [self _routesControllerForRoute:route];
    NSMutableDictionary *routerParameters = [router achieveParametersFromURL:route];
    if(!routerParameters){
       ZSRouterErrorLog(@"Route unregistered URL:%@",route);
        [router unregisterURLBeRouterWithRoute:route withParameters:parameters];
        return NO;
    }

    [routerParameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            routerParameters[key] = [NSString stringWithFormat:@"%@",obj];
        }
    }];

    if (routerParameters) {
        NSDictionary *coreDic = routerParameters[ZSRouterCoreKey];
        ZSCallbackRouterHandler handler = coreDic[ZSRouterCoreBlockKey];
        ZSRouterType type = [coreDic[ZSRouterCoreTypeKey] integerValue];
        if (type != ZSRouterTypeCallback) {
            [self routeTypeCheckLogWithCorrectType:type url:route];
            return NO;
        }
        if (parameters) {
            [routerParameters addEntriesFromDictionary:parameters];
        }

        if (handler) {
            [routerParameters removeObjectForKey:ZSRouterCoreKey];
            handler(routerParameters,^(id callbackObjc){
                if (targetCallback) {
                    targetCallback(callbackObjc);
                }
            });
        }
    }
    return YES;
}


#pragma mark - private Methods

+ (instancetype)_routesControllerForRoute:(NSString *)route
{
    NSURL *URL = [NSURL URLWithString:route];
    if (URL == nil) {
        return nil;
    }
    return ZSRGlobal_routerControllersMap[URL.scheme] ?: [ZSRouter globalRouter];
}

#pragma mark - 注册URL
- (void)registerRouteURL:(NSString *)routeURL handler:(ZSRouterHandler)handlerBlock {
//    FFRouterLog(@"registerRouteURL:%@",routeURL);
    [self addRouteURL:routeURL handler:handlerBlock];
}

- (void)registerObjectRouteURL:(NSString *)routeURL handler:(ZSObjectRouterHandler)handlerBlock {
//    FFRouterLog(@"registerObjectRouteURL:%@",routeURL);
    [self addObjectRouteURL:routeURL handler:handlerBlock];
}

- (void)registerCallbackRouteURL:(NSString *)routeURL handler:(ZSCallbackRouterHandler)handlerBlock {
//    FFRouterLog(@"registerCallbackRouteURL:%@",routeURL);
    [self addCallbackRouteURL:routeURL handler:handlerBlock];
}

#pragma mark  Private-Methods
- (void)addRouteURL:(NSString *)routeUrl handler:(ZSRouterHandler)handlerBlock {
    NSMutableDictionary *subRoutes = [self addURLPattern:routeUrl];
    if (handlerBlock && subRoutes) {
        NSDictionary *coreDic = @{ZSRouterCoreBlockKey:[handlerBlock copy],ZSRouterCoreTypeKey:@(ZSRouterTypeDefault)};
        subRoutes[ZSRouterCoreKey] = coreDic;
    }
}

- (void)addObjectRouteURL:(NSString *)routeUrl handler:(ZSObjectRouterHandler)handlerBlock {
    NSMutableDictionary *subRoutes = [self addURLPattern:routeUrl];
    if (handlerBlock && subRoutes) {
        NSDictionary *coreDic = @{ZSRouterCoreBlockKey:[handlerBlock copy],ZSRouterCoreTypeKey:@(ZSRouterTypeObject)};
        subRoutes[ZSRouterCoreKey] = coreDic;
    }
}

- (void)addCallbackRouteURL:(NSString *)routeUrl handler:(ZSCallbackRouterHandler)handlerBlock {
    NSMutableDictionary *subRoutes = [self addURLPattern:routeUrl];
    if (handlerBlock && subRoutes) {
        NSDictionary *coreDic = @{ZSRouterCoreBlockKey:[handlerBlock copy],ZSRouterCoreTypeKey:@(ZSRouterTypeCallback)};
        subRoutes[ZSRouterCoreKey] = coreDic;
    }
}

- (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern {
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];
    NSMutableDictionary* subRoutes = self.routes;
    for (NSString* pathComponent in pathComponents) {
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
    }
    return subRoutes;
}

#pragma mark URL PATH
- (NSArray*)pathComponentsFromURL:(NSString*)URL {
    
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [URL componentsSeparatedByString:@"://"];
        [pathComponents addObject:pathSegments[0]];
        for (NSInteger idx = 1; idx < pathSegments.count; idx ++) {
            if (idx == 1) {
                URL = [pathSegments objectAtIndex:idx];
            }else{
                URL = [NSString stringWithFormat:@"%@://%@",URL,[pathSegments objectAtIndex:idx]];
            }
        }
    }
    
    if ([URL hasPrefix:@":"]) {
        if ([URL rangeOfString:@"/"].location != NSNotFound) {
            NSArray *pathSegments = [URL componentsSeparatedByString:@"/"];
            [pathComponents addObject:pathSegments[0]];
        }else{
            [pathComponents addObject:URL];
        }
    }else{
        for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
            if ([pathComponent isEqualToString:@"/"]) continue;
            if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
            [pathComponents addObject:pathComponent];
        }
    }
    return [pathComponents copy];
}

- (NSMutableDictionary *)achieveParametersFromURL:(NSString *)url{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[ZSRouterParameterURLKey] = [url stringByRemovingPercentEncoding];
    NSMutableDictionary* subRoutes = self.routes;
    NSArray* pathComponents = [self pathComponentsFromURL:url];
    
    NSInteger pathComponentsSurplus = [pathComponents count];
    BOOL wildcardMatched = NO;
    
    for (NSString* pathComponent in pathComponents) {
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch;
        NSArray *subRoutesKeys =[subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj2 compare:obj1 options:comparisonOptions];
        }];
        
        for (NSString* key in subRoutesKeys) {
            
            if([pathComponent isEqualToString:key]){
                pathComponentsSurplus --;
                subRoutes = subRoutes[key];
                break;
            }else if([key hasPrefix:@":"] && pathComponentsSurplus == 1){
                subRoutes = subRoutes[key];
                NSString *newKey = [key substringFromIndex:1];
                NSString *newPathComponent = pathComponent;
                
                NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:ZSSpecialCharacters];
                NSRange range = [key rangeOfCharacterFromSet:specialCharacterSet];
                
                if (range.location != NSNotFound) {
                    newKey = [newKey substringToIndex:range.location - 1];
                    NSString *suffixToStrip = [key substringFromIndex:range.location];
                    newPathComponent = [newPathComponent stringByReplacingOccurrencesOfString:suffixToStrip withString:@""];
                }
                parameters[newKey] = newPathComponent;
                break;
            }else if([key isEqualToString:ZSRouterWildcard] && !wildcardMatched){
                subRoutes = subRoutes[key];
                wildcardMatched = YES;
                break;
            }
        }
    }
    
    if (!subRoutes[ZSRouterCoreKey]) {
        return nil;
    }
    
    NSArray<NSURLQueryItem *> *queryItems = [[NSURLComponents alloc] initWithURL:[[NSURL alloc] initWithString:url] resolvingAgainstBaseURL:false].queryItems;
    
    for (NSURLQueryItem *item in queryItems) {
        parameters[item.name] = item.value;
    }
    
    parameters[ZSRouterCoreKey] = [subRoutes[ZSRouterCoreKey] copy];
    return parameters;
}

+ (void)routeTypeCheckLogWithCorrectType:(ZSRouterType)correctType url:(NSString *)URL{
    if (correctType == ZSRouterTypeDefault) {
       ZSRouterErrorLog(@"You must use [exeRoute:] or [exeRoute: withParameters:] to Route URL:%@",URL);
        NSAssert(NO, @"Method using errors, please see the console log for details.");
    }else if (correctType == ZSRouterTypeObject) {
       ZSRouterErrorLog(@"You must use [exeObjectRoute:] or [exeObjectRoute: withParameters:] to Route URL:%@",URL);
        NSAssert(NO, @"Method using errors, please see the console log for details.");
    }else if (correctType == ZSRouterTypeCallback) {
       ZSRouterErrorLog(@"You must use [exeCallbackRoute: targetCallback:] or [exeCallbackRoute: withParameters: targetCallback:] to Route URL:%@",URL);
        NSAssert(NO, @"Method using errors, please see the console log for details.");
    }
}
#pragma mark 监听
- (void)unregisterURLBeRouterWithRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *)parameters{
    if (self.routerUnregisterURLHandler) {
        self.routerUnregisterURLHandler(route, parameters);
    }
}
#pragma mark - getter/setter
- (NSMutableDictionary *)routes {
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}
- (NSString *)getRouteURL:(NSString *)routePattern
{
    NSString *routeURL = [[NSString stringWithFormat:@"%@://",self.scheme] stringByAppendingPathComponent:routePattern];
    return routeURL;
}

@end

@implementation ZSRouter (Util)

/// 尝试push，如果objVC是一个UIViewController,则进行push；如果不是返回NO
/// @param objVC 疑是UIViewController对象

+ (BOOL)tryPushVC:(id)objVC
{
    if (![objVC isKindOfClass:[UIViewController class]]) {
        return NO;
    }
    UIViewController *vc = (UIViewController *)objVC;
    [ZSRouterNavigation pushViewController:vc animated:YES];
    return YES;
}

@end

@implementation ZSRouter (AppScheme)

/// 快速获取APP的scheme值；会从mainbundle的Info.plist中获取“app_router_scheme”配置的值；
+ (NSString *)appScheme
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *scheme = [infoDictionary objectForKey:@"app_router_scheme"];
    return scheme;
}

/// 快速获取APP的scheme值,并根据routePattern拼接为route地址
/// @param routePattern routePattern
+ (NSString *)appSchemeRoute:(NSString *)routePattern
{
    NSString *scheme = [ZSRouter appScheme];
    NSString *route = [NSString stringWithFormat:@"%@://%@", scheme,routePattern];
    return route;
}
// 注册
+ (void)addAppSchemeRoute:(NSString *)routePattern handler:(ZSRouterHandler)handlerBlock{
    [ZSRouter checkAppSchemeUrl:routePattern];
    ZSRouter *router = [ZSRouter routerForScheme:ZSAppScheme];
    [router addRoute:routePattern handler:handlerBlock];
}
+ (void)addAppSchemeObjectRoute:(NSString *)routePattern handler:(ZSObjectRouterHandler)handlerBlock{
    [ZSRouter checkAppSchemeUrl:routePattern];
    ZSRouter *router = [ZSRouter routerForScheme:ZSAppScheme];
    [router addObjectRoute:routePattern handler:handlerBlock];
}
+ (void)addAppSchemeCallbackRoute:(NSString *)routePattern handler:(ZSCallbackRouterHandler)handlerBlock{
    [ZSRouter checkAppSchemeUrl:routePattern];
    ZSRouter *router = [ZSRouter routerForScheme:ZSAppScheme];
    [router addCallbackRoute:routePattern handler:handlerBlock];
}
// 执行
+ (BOOL)exeAppSchemeRoute:(NSString *)route{
    [ZSRouter checkAppSchemeUrl:route];
    return [ZSRouter exeRoute:ZSAppRoute(route)];
}
+ (BOOL)exeAppSchemeRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters{
    [ZSRouter checkAppSchemeUrl:route];
    return [ZSRouter exeRoute:ZSAppRoute(route) withParameters:parameters];
}
+ (id _Nullable )exeAppSchemeObjectRoute:(NSString *_Nullable)route{
    [ZSRouter checkAppSchemeUrl:route];
    return [ZSRouter exeObjectRoute:ZSAppRoute(route)];
}
+ (id _Nullable )exeAppSchemeObjectRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters{
    [ZSRouter checkAppSchemeUrl:route];
    return [ZSRouter exeObjectRoute:ZSAppRoute(route) withParameters:parameters];
}
+ (BOOL)exeAppSchemeCallbackRoute:(NSString *)route targetCallback:(ZSRouterCallback _Nullable )targetCallback{
    [ZSRouter checkAppSchemeUrl:route];
    return [ZSRouter exeCallbackRoute:ZSAppRoute(route) targetCallback:targetCallback];
}
+ (BOOL)exeAppSchemeCallbackRoute:(NSString *)route withParameters:(NSDictionary<NSString *, id> *_Nullable)parameters targetCallback:(ZSRouterCallback _Nullable)targetCallback{
    [ZSRouter checkAppSchemeUrl:route];
    return [ZSRouter exeCallbackRoute:ZSAppRoute(route) withParameters:parameters targetCallback:targetCallback];
}

+ (void)checkAppSchemeUrl:(NSString *)route{
    if (!route || [route isEqualToString:@""]) {
        ZSRouterErrorLog(@"Route Url should not be null !");
    }
    if ([route containsString:@"://"]) {
        ZSRouterErrorLog(@"使用Default Route方法，不需要额外添加Scheme !");
    }
}

@end
