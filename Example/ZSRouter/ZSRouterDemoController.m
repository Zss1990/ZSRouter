//
//  ZSRouterDemoController.m
//  ZSRouter_Example
//
//  Created by shuaishuai on 2021/2/19.
//  Copyright © 2021 zhushuaishuai. All rights reserved.
//

#import "ZSRouterDemoController.h"
#import <ZSRouter/ZSRouter.h>
#import <ZSRouter/ZSRouterRewrite.h>
#import "RouterDetailController.h"
#import "RouterCallbackController.h"
#import "ZSRouterLogger.h"
#import "ZSRouterNavigation.h"

@interface ZSRouterDemoController ()
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@end

@implementation ZSRouterDemoController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"ZSRouter";
    [ZSRouter setLogEnabled:YES];
    
    [self addRoute];
    [self rewriteMatchRules];
}

- (void)addRoute
{
//    ZSRouter *router1 = [ZSRouter routerForScheme:@"myAPP"];
//    ZSRouter *router1 = [ZSRouter routerForScheme:[ZSRouter appScheme]];
    ZSRouter *router1 = [ZSRouter routerForScheme:ZSAppScheme];
    
    [router1 addRoute:@"page/detailvc" handler:^(NSDictionary<NSString *,id> * _Nullable routerParameters) {
        NSLog(@"page/detailvc --->: %@",routerParameters);
    }];
    
    [router1 addObjectRoute:@"page/detailvc/obj" handler:^id _Nullable(NSDictionary<NSString *,id> * _Nullable routerParameters) {
        NSLog(@"page/detailvc/obj --->: %@",routerParameters);
        RouterDetailController *mRouterDetailController = [[RouterDetailController alloc]init];
        [mRouterDetailController addLogText:[self dictionaryToJson:routerParameters]];
        [mRouterDetailController setLogImage:[routerParameters objectForKey:@"img"]];
        return mRouterDetailController;
    }];
    
    [router1 addCallbackRoute:@"page/detailvc/callback" handler:^(NSDictionary<NSString *,id> * _Nullable routerParameters, ZSRouterCallback  _Nullable targetCallback) {
        NSLog(@"page/detailvc/callback --->: %@",routerParameters);
        RouterCallbackController *mRouterCallbackController = [[RouterCallbackController alloc]init];
        mRouterCallbackController.infoStr = [NSString stringWithFormat:@"%@",routerParameters];
        [mRouterCallbackController testCallBack:targetCallback];
        [self.navigationController pushViewController:mRouterCallbackController animated:YES];
    }];
    
    // 监听
    [router1 monitorExeUnregisterRouteHandler:^(NSString * _Nullable route, NSDictionary<NSString *,id> * _Nullable parameters) {
        NSLog(@"monitorExeUnregisterRouteHandler --->:%@ - %@",route,parameters);
    }];
    
    ZSRouter *router11 = [ZSRouter routerForScheme:@"myAPP"];
    NSLog(@"--->: %p - %p",router1,router11);
    
    // 通配符
    [[ZSRouter routerForScheme:@"https"] addRoute:@"www.baidu.com/*" handler:^(NSDictionary<NSString *,id> * _Nullable routerParameters) {
        NSLog(@"https://www.baidu.com/* --->: %@",routerParameters);
    }];
    [[ZSRouter routerForScheme:@"wildcard"] addRoute:@"*" handler:^(NSDictionary<NSString *,id> * _Nullable routerParameters) {
        NSLog(@"wildcard://* --->: %@",routerParameters);
    }];
    
    //注册 Rewrite一个URL
    [[ZSRouter routerForScheme:@"httpsprotocol"] addObjectRoute:@"page/routerDetails" handler:^id _Nullable(NSDictionary<NSString *,id> * _Nullable routerParameters) {
        NSLog(@"page/detailvc/obj --->: %@",routerParameters);
        RouterDetailController *mRouterDetailController = [[RouterDetailController alloc]init];
        [mRouterDetailController addLogText:[routerParameters objectForKey:@"product"]];
        return mRouterDetailController;
    }];
}

- (void)rewriteMatchRules {
    [ZSRouterRewrite addRewriteMatchRule:@"(?:https://)?www.taobao.com/search/(.*)" targetRule:@"httpsprotocol://page/routerDetails?product=$1"];
}

// addRoute
- (IBAction)btnClick1:(id)sender {
    ZSRouterLog(@"btnClick1");
//    [ZSRouter exeRoute:@"myAPP://page/detailvc" withParameters:@{@"KEY1":@"btnClick1"}];
//    [ZSRouter exeRoute:[ZSRouter appSchemeRoute:@"page/detailvc"] withParameters:@{@"KEY1":@"btnClick1"}];
    [ZSRouter exeRoute:ZSAppRoute(@"page/detailvc") withParameters:@{@"KEY1":@"btnClick1"}];
}

// 携带对象参数
- (IBAction)btnClick2:(id)sender {
    UIImage *img = [UIImage imageNamed:@"router_icon"];
    [ZSRouter exeRoute:ZSAppRoute(@"page/detailvc") withParameters:@{@"KEY1":@"btnClick2",@"img":(img?:@"")}];
}

//返回addObjectRoute对象
- (IBAction)btnClick3:(id)sender {
    UIImage *img = [UIImage imageNamed:@"router_icon"];
//    id obj = [ZSRouter exeObjectRoute:@"myAPP://page/detailvc/obj" withParameters:@{@"KEY1":@"btnClick3",@"img":(img?:@"")}];
    id obj = [ZSRouter exeObjectRoute:ZSAppRoute(@"page/detailvc/obj") withParameters:@{@"KEY1":@"btnClick3",@"img":(img?:@"")}];
    [self tryPushVC:obj];
    NSLog(@"--->: %s - %@",__func__,obj);
}

//addCallbackRoute异步返回
- (IBAction)btnClick4:(id)sender {
//    [ZSRouter exeCallbackRoute:@"myAPP://page/detailvc/callback" withParameters:@{@"KEY1":@"btnClick3"} targetCallback:^(id  _Nullable callbackObjc) {
//        NSLog(@"--->: %s - %@",__func__,callbackObjc);
//        [self.testLabel setText:callbackObjc];
//    }];
    [ZSRouter exeCallbackRoute:ZSAppRoute(@"page/detailvc/callback") withParameters:@{@"KEY1":@"btnClick3"} targetCallback:^(id  _Nullable callbackObjc) {
        NSLog(@"--->: %s - %@",__func__,callbackObjc);
        [self.testLabel setText:callbackObjc];
    }];
}

//通配符(*)方式注册URL
- (IBAction)btnClick5:(id)sender {
    [ZSRouter exeRoute:@"https://www.baidu.com/path1/path2" withParameters:@{@"KEY1":@"btnClick5",@"URL":@"https://www.baidu.com/path1/path2"}];
    [ZSRouter exeRoute:@"wildcard://host/path1/path2" withParameters:@{@"KEY1":@"btnClick5",@"URL":@"wildcard://host/path1/path2"}];
}

// route一个未注册的URL
- (IBAction)btnClick6:(id)sender {
    [ZSRouter exeRoute:@"myAPP://host/path1/path2" withParameters:@{@"KEY1":@"btnClick6",@"URL":@"myAPP://host/path1/path2"}];
    [ZSRouter exeRoute:@"YOU://host/path1/path2" withParameters:@{@"KEY1":@"btnClick6",@"URL":@"YOU://host/path1/path2"}];
}

// Rewrite一个URL
- (IBAction)btnClick7:(id)sender {
    id obj = [ZSRouter exeObjectRoute:@"https://www.taobao.com/search/我被修改了并作为了参数"];
    [self tryPushVC:obj];
    NSLog(@"--->: %s - %@",__func__,obj);
//    [ZSRouter exeObjectRoute:@"https://www.taobao.com/search/wowoowowo"];
}

- (IBAction)pushBtnClick:(id)sender {
        UIAlertController *alerCtrl = [UIAlertController alertControllerWithTitle:@"测试" message:@"测试当前视图" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        [alerCtrl addAction:action];
        [self presentViewController:alerCtrl animated:YES completion:^{
            UIViewController *curvc = [ZSRouterNavigation currentViewController];
            NSLog(@"-->: %@",curvc);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            RouterDetailController *mRouterDetailController = [[RouterDetailController alloc]init];
    //        [curvc.navigationController pushViewController:mRouterDetailController animated:YES];
            [ZSRouterNavigation pushViewController:mRouterDetailController animated:YES];
        });
}

#pragma mark - private

/// 尝试push，如果objVC是一个UIViewController；如果不是返回NO
/// @param objVC 疑是UIViewController对象

- (BOOL)tryPushVC:(id)objVC
{
    if (![objVC isKindOfClass:[UIViewController class]]) {
        return NO;
    }
    UIViewController *vc = (UIViewController *)objVC;
    [self.navigationController pushViewController:vc animated:YES];
    return YES;
}

//字典转json格式字符串：
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSString *str = nil;
    @try {
        NSError *parseError = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
        str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        str = [NSString stringWithFormat:@"%@",dic];
    }
    return str;
}

@end
