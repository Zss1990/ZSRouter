//
//  ZSRouterLogger.h
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define ZSRouterLogLevel(lvl,fmt,...)\
[ZSRouterLogger log : YES                                      \
level : lvl                                                  \
format : (fmt), ## __VA_ARGS__]

#define ZSRouterLog(fmt,...)\
ZSRouterLogLevel(ZSRouterLoggerLevelInfo,(fmt), ## __VA_ARGS__)

#define ZSRouterWarningLog(fmt,...)\
ZSRouterLogLevel(ZSRouterLoggerLevelWarning,(fmt), ## __VA_ARGS__)

#define ZSRouterErrorLog(fmt,...)\
ZSRouterLogLevel(ZSRouterLoggerLevelError,(fmt), ## __VA_ARGS__)


typedef NS_ENUM(NSUInteger,ZSRouterLoggerLevel){
    ZSRouterLoggerLevelInfo = 1,
    ZSRouterLoggerLevelWarning ,
    ZSRouterLoggerLevelError ,
};

@interface ZSRouterLogger : NSObject

@property(class , readonly, strong) ZSRouterLogger *sharedInstance;

+ (BOOL)isLoggerEnabled;

+ (void)enableLog:(BOOL)enableLog;

+ (void)log:(BOOL)asynchronous
      level:(NSInteger)level
     format:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
