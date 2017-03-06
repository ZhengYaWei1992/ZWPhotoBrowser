//
//  ZWPhotoBrowser.h
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZWPhotoBrowser;
@protocol ZWPhotoBrowserDelegate <NSObject>

@required
//设置对应index下的小图像   这是必须实现的方法
//之所以通过一个代理方法实现，当imageView的容器视图为一般的UIView的时候没有问题。但是当容器视图为UICollectionView的时候，通过sourceImagesContainerView还要做额外判断，情况不定。所以通过代理更为合理
- (UIImage *)photoBrowser:(ZWPhotoBrowser *)browser smallImageForIndex:(NSInteger)index;
@optional
//设置对应index的高清图片地址
- (NSURL *)photoBrowser:(ZWPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index;

@end

@interface ZWPhotoBrowser : UIView<UIScrollViewDelegate>

/**
 imageView容器视图
 */
@property(nonatomic,weak)UIView *sourceImagesContainerView;
/**
 当前选中的imageView下标
 */
@property (nonatomic, assign) NSInteger currentImageIndex;
/**
 imageView的总个数
 */
@property (nonatomic, assign) NSInteger imageCount;
@property (nonatomic, weak) id<ZWPhotoBrowserDelegate> delegate;

/**
 展占位图
 */
@property(nonatomic,strong)UIImage *placeholderImage;

- (void)show;

@end
