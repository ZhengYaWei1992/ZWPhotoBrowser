//
//  ZWBrowserImageView.h
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWWaitingView.h"

@interface ZWBrowserImageView : UIImageView<UIGestureRecognizerDelegate>

/**
 图片加载进度
 */
@property (nonatomic, assign) CGFloat progress;
/**
 图片是否处于缩放状态
 */
@property (nonatomic, assign, readonly) BOOL isScaled;

/**
 图片是否加载完成
 */
@property (nonatomic, assign) BOOL hasLoadedImage;


/**
 清除缩放
 */
- (void)eliminateScale;
/**
 设置图片
 */
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
/**
 双击缩放事件
 @param scale 缩放比例
 */
- (void)doubleTapToZommWithScale:(CGFloat)scale;

- (void)clear;

@end
