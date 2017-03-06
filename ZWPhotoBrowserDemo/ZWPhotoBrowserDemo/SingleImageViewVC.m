//
//  SingleImageViewVC.m
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "SingleImageViewVC.h"
#import "ZWBrowserImageView.h"

@interface SingleImageViewVC ()

@end

@implementation SingleImageViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    ZWBrowserImageView *iv = [[ZWBrowserImageView alloc]initWithFrame:CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 80 - 49)];
    [iv setImageWithURL:[NSURL URLWithString:@"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417292422.jpg"] placeholderImage:[UIImage imageNamed:@"placholder"]];
    [self.view addSubview:iv];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
}

@end
