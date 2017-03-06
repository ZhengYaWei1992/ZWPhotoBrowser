//
//  ZWPhototBrowserConfig.h
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#ifndef ZWPhototBrowserConfig_h
#define ZWPhototBrowserConfig_h

typedef enum {
    ZWWaitingViewModeLoopDiagram, // 环形
    ZWWaitingViewModePieDiagram // 饼型
} ZWWaitingViewMode;

// 图片保存成功提示文字
#define ZWPhotoBrowserSaveImageSuccessText @"图片保存成功 ";

// 图片保存失败提示文字
#define ZWPhotoBrowserSaveImageFailText @"图片保存失败 ";

// browser背景颜色
#define ZWPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// browser中图片间的margin
#define ZWPhotoBrowserImageViewMargin 10

// browser中显示图片动画时长
#define ZWPhotoBrowserShowImageAnimationDuration 0.4f

// browser中显示图片动画时长
#define ZWPhotoBrowserHideImageAnimationDuration 0.4f


// 图片下载进度指示器背景色
#define ZWWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

// 图片下载进度指示器内部控件间的间距
#define ZWWaitingViewItemMargin 2

#endif /* ZWPhototBrowserConfig_h */
