//
//  RouterDetailController.m
//  FFMainProject
//
//  Created by shuaishuai on 2021/2/19.
//  Copyright © 2021 zhushuaishuai. All rights reserved.
//

#import "RouterDetailController.h"

@interface RouterDetailController ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImgView;

@property (nonatomic,strong) NSString *logText;
@property (nonatomic,strong) UIImage *logImg;

@end

@implementation RouterDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configBaseView];
    [self showDetailData];
}

- (void)configBaseView {
    self.navigationItem.title = @"RouterDetailController";
}

- (void)showDetailData {
    self.contentLabel.text = self.logText;
    self.contentImgView.image = self.logImg;
}

- (void)addLogText:(NSString *)text {
    if (self.logText.length > 0) {
        self.logText = [NSString stringWithFormat:@"%@\n------------------------\n%@",self.logText,text];
    }else{
        self.logText = text;
    }
}

- (void)setLogImage:(UIImage *)image {
    self.logImg = image;
}

- (NSString *)testDetailObjectResult {
    return @"这是来自RouterDetailController的字符串";
}


@end
