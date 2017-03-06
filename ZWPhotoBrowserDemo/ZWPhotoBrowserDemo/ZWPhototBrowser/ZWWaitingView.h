//
//  ZWWaitingView.h
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWPhototBrowserConfig.h"

@interface ZWWaitingView : UIView

/**
 图片加载进度
 */
@property (nonatomic, assign) CGFloat progress;

/**
 加载进度图形的样式 （环形和饼形）
 */
@property (nonatomic, assign) int mode;

@end
