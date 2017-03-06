//
//  ZWWaitingView.m
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWWaitingView.h"

@implementation ZWWaitingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = ZWWaitingViewBackgroundColor;
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        //环形
        self.mode = ZWWaitingViewModeLoopDiagram;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    //重绘放置在主线程，解决自动布局控制台报错的问题
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
        if (progress >= 1) {
            [self removeFromSuperview];
        }
    });
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    [[UIColor whiteColor] set];
    
    switch (self.mode) {
            //饼形
        case ZWWaitingViewModePieDiagram:
        {
            //扇形的半径
            CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - ZWWaitingViewItemMargin;
            
            //CGFloat w = radius * 2 + ZWWaitingViewItemMargin;
            CGFloat w = radius * 2;
            CGFloat h = w;
            CGFloat x = (rect.size.width - w) * 0.5;
            CGFloat y = (rect.size.height - h) * 0.5;
            CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
            CGContextFillPath(ctx);
            
            //扇形的背景颜色
            //[ZWWaitingViewBackgroundColor set];
            [[UIColor lightGrayColor]set];
            
            CGContextMoveToPoint(ctx, xCenter, yCenter);
            CGContextAddLineToPoint(ctx, xCenter, 0);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
            CGContextClosePath(ctx);
            
            CGContextFillPath(ctx);
        }
            break;
            //环形
        default:
        {
            CGContextSetLineWidth(ctx, 15);
            CGContextSetLineCap(ctx, kCGLineCapRound);
            CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.05; // 初始值0.05
            CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.5 - ZWWaitingViewItemMargin;
            CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 0);
            CGContextStrokePath(ctx);
        }
            break;
    }
}

@end
