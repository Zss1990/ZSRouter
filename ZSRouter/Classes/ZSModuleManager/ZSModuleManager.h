//
//  ZSModuleManager.h
//  ZSRouter
//
//  Created by shuaishuai on 2021/2/20.
//

#import <Foundation/Foundation.h>
@protocol ZSModuleProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface ZSModuleItem : NSObject
@property (nonatomic, assign) NSInteger priority;
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) id module;

- (instancetype)initWithModule:(id)module
                      priority:(NSInteger)priority
                      sequence:(NSInteger)sequence;
@end


@interface ZSModuleManager : NSObject
+ (instancetype)instance;

+ (void)registerModuleClass:(Class <ZSModuleProtocol>)moduleClass
                     config:(NSDictionary *)config
                   priority:(NSInteger)priority;

- (id)moduleInstanceByName:(NSString *)moduleName;

- (void)enumerateModulesUsingBlock:(__attribute__((noescape)) void (^)(id module, BOOL *stop))block;

@end


@interface ZSModuleManager (AppDelegate)<UIApplicationDelegate>

@end

NS_ASSUME_NONNULL_END
