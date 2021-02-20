//
//  RouterCallbackController.h
//  FFRouterDemo
//
//  Created by shuaishuai on 2021/2/19.
//  Copyright © 2021 zhushuaishuai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TestCallback)(NSString *callbackStr);

@interface RouterCallbackController : UIViewController

-(void)testCallBack:(TestCallback)callback;

@property (nonatomic,strong) NSString *infoStr;

@end
