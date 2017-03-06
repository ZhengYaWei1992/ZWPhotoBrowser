//
//  ViewController.m
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "SingleImageViewVC.h"
#import "ZWPhotoBrowser.h"


@interface ViewController ()<ZWPhotoBrowserDelegate>
@property(nonatomic,strong)NSMutableArray *smallPicsUrls;
@property(nonatomic,strong)NSMutableArray *bigPicsUrls;
@property(nonatomic,strong)UIView *containerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _containerView = [[UIView alloc] init];
    _containerView.bounds = CGRectMake(0, 0, 340, 340);
    _containerView.backgroundColor = [UIColor lightGrayColor];
    _containerView.center = self.view.center;
    [self.view addSubview:_containerView];
    
    NSInteger column = 0;
    NSInteger row = 0;
    CGFloat ivX = 0;
    CGFloat ivY = 0;
    CGFloat ivW = 100;
    CGFloat padding = 10;
    for (NSUInteger i=0; i <self.smallPicsUrls.count; i++) {
        UIImageView *iv = [UIImageView new];
        [iv sd_setImageWithURL:[NSURL URLWithString:self.smallPicsUrls[i]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        iv.tag = i;
        iv.userInteractionEnabled = YES;
        column = i % 3;
        row = i /3;
        ivX = padding + (ivW + padding) * column;
        ivY = padding + (ivW + padding) * row;
        iv.frame = CGRectMake(ivX, ivY, ivW, ivW);
        [_containerView addSubview:iv];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ivTap:)];
        [iv addGestureRecognizer:tap];
    }
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"单张图片测试" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(imageViewTestClick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(self.view.frame.size.width/2 - 100, CGRectGetMaxY(_containerView.frame) + 50, 200, 40);
    [self.view addSubview:button];
}
//单张图片测试
- (void)imageViewTestClick:(UIButton *)btn{
    SingleImageViewVC *vc = [[SingleImageViewVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)ivTap:(UITapGestureRecognizer *)tap{
    NSLog(@"%ld",tap.view.tag);
    ZWPhotoBrowser *photoBrowser = [[ZWPhotoBrowser alloc]init];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = tap.view.tag;
    photoBrowser.imageCount = self.smallPicsUrls.count;
    photoBrowser.sourceImagesContainerView = _containerView;
    photoBrowser.placeholderImage = [UIImage imageNamed:@"placeholder"];
    [photoBrowser show];
}

#pragma mark -ZWPhotoBrowserDelegate
/**
 返回高清图像的URL，如果没有写这个方法，则显示小图像
 */
- (NSURL *)photoBrowser:(ZWPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:self.bigPicsUrls[index]];
}
/**
 获取imageView上的原本小图  这是必须实现的代理方法
 主要是为了设置动画效果
 */
- (UIImage *)photoBrowser:(ZWPhotoBrowser *)browser smallImageForIndex:(NSInteger)index{
    UIImageView *imageView = self.containerView.subviews[index];
    return imageView.image;
}




- (NSMutableArray *)smallPicsUrls{
    if (_smallPicsUrls == nil) {
        _smallPicsUrls = [NSMutableArray arrayWithObjects:
                          @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160503/14622764778932thumbnail.jpg",
                          @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160426/14616659617000.jpg",
                          @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636463273461.JPEG",
                          @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417251890thumbnail.jpg",
                          @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417276631thumbnail.jpg",
                          @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417292432thumbnail.jpg",
                           nil];
    }
    return _smallPicsUrls;
}
- (NSMutableArray *)bigPicsUrls{
    if (_bigPicsUrls == nil) {
        _bigPicsUrls = [NSMutableArray arrayWithObjects:
                        @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160503/14622764778932thumbnail.jpg",
                        @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160426/14616659617000.jpg",
                        @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636463273461.JPEG",
                        @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417251850.jpg",
                        @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417276611.jpg",
                        @"http://weixintest.ihk.cn/ihkwx_upload/commentPic/20160519/14636417292422.jpg",
                        nil];
    }
    return _bigPicsUrls;
}



@end
