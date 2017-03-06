//
//  ZWBrowserImageView.m
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWBrowserImageView.h"
#import "UIImageView+WebCache.h"
#import "ZWPhototBrowserConfig.h"

@interface ZWBrowserImageView ()

/**
 缩放比例
 */
@property(nonatomic,assign)CGFloat totalScale;
/**
 图片加载进度视图
 */
@property(nonatomic,weak)ZWWaitingView *waitingView;


/**
 用于非缩放状态下常规图片展示的UIScrollView   可能有长图，所以用UIScrollView
 */
@property(nonatomic,strong)UIScrollView *scroll;
/**
 非缩放状态下的imageView
 */
@property(nonatomic,strong)UIImageView *scrollImageView;


/**
 用于缩放状态下图片展示的UIScrollView
 */
@property(nonatomic,strong)UIScrollView *zoomingScrollView;
/**
 缩放状态下的imageView
 */
@property(nonatomic,strong)UIImageView *zoomingImageView;

@end


@implementation ZWBrowserImageView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        _totalScale = 1.0;
        //添加捏合手势  缩放图片
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
        pinch.delegate = self;
        [self addGestureRecognizer:pinch];
    }
    return self;
}




- (void)layoutSubviews{
    [super layoutSubviews];
    _waitingView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    CGSize imageSize = self.image.size;
    if (self.bounds.size.width * (imageSize.height / imageSize.width) > self.bounds.size.height) {
        //1.创建scroll
        //2.将self赋值给 _scrollImageView，并放置在scroll上
        //3.scroll放置在self上面，并让waitingView显示在最前方
        //即视图从上到下依次为waitingView、scrollImageView、scroll、self,所以一般显示的时候显示的是scrollImageView，显示的背景是scroll的背景颜色。
        //懒加载的形式创建scroll
        if (!_scroll) {
            UIScrollView *scroll = [[UIScrollView alloc] init];
            scroll.backgroundColor = [UIColor whiteColor];
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = self.image;
            _scrollImageView = imageView;
            [scroll addSubview:imageView];
            scroll.backgroundColor = ZWPhotoBrowserBackgrounColor;
            _scroll = scroll;
            [self addSubview:scroll];
            if (_waitingView) {
                [self bringSubviewToFront:_waitingView];
            }
        }
        _scroll.frame = self.bounds;
        CGFloat imageViewH = self.bounds.size.width * (imageSize.height / imageSize.width);
        _scrollImageView.bounds = CGRectMake(0, 0, _scroll.frame.size.width, imageViewH);
        _scrollImageView.center = CGPointMake(_scroll.frame.size.width * 0.5, _scrollImageView.frame.size.height * 0.5);
        _scroll.contentSize = CGSizeMake(0, _scrollImageView.bounds.size.height);
    }else{
        // 防止旋转时适配的scrollView的影响？？？？？？？？？？？
        if (_scroll) [_scroll removeFromSuperview];
    }
}


#pragma mark -手势捏合事件
- (void)zoomImage:(UIPinchGestureRecognizer *)recognizer{
    [self prepareForImageViewScaling];
    //设置缩放比例
    CGFloat scale = recognizer.scale;
    CGFloat temp = _totalScale + (scale - 1);
    [self setTotalScale:temp];
    recognizer.scale = 1.0;
}
//设置缩放比例
- (void)setTotalScale:(CGFloat)totalScale{
    //最大缩放 2倍,最小0.5倍
    if ((_totalScale < 0.5 && totalScale < _totalScale) || (_totalScale > 2.0 && totalScale > _totalScale)){
        return;
    }
    [self zoomWithScale:totalScale];
}
- (void)zoomWithScale:(CGFloat)scale{
    _totalScale = scale;
    _zoomingImageView.transform = CGAffineTransformMakeScale(scale, scale);
    if (scale > 1) {//放大
        CGFloat contentW = _zoomingImageView.frame.size.width;
        //？？？？？
        CGFloat contentH = MAX(_zoomingImageView.frame.size.height, self.frame.size.height);
        
        _zoomingImageView.center = CGPointMake(contentW * 0.5, contentH * 0.5);
        _zoomingScrollView.contentSize = CGSizeMake(contentW, contentH);
        
        
        CGPoint offset = _zoomingScrollView.contentOffset;
        offset.x = (contentW - _zoomingScrollView.frame.size.width) * 0.5;
        //开启了这句话，放大啊图片的时候会产生错位，体验效果不是很好
        //offset.y = (contentH - _zoomingImageView.frame.size.height) * 0.5;
        _zoomingScrollView.contentOffset = offset;
    }else{//缩小
        _zoomingScrollView.contentSize = _zoomingScrollView.frame.size;
        //缩小时，同时设置内容填充边距为0
        _zoomingScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _zoomingImageView.center = _zoomingScrollView.center;
    }
}

//手势捏合的前期相关控件创建和布局准备
- (void)prepareForImageViewScaling{
    /*
     层次结构分析说明：
     1.zoomingImageView放置在zoomingScrollView上
     2.zoomingScrollView放置在self上面
     */
    if (!_zoomingScrollView) {
        _zoomingScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _zoomingScrollView.backgroundColor = ZWPhotoBrowserBackgrounColor;
        _zoomingScrollView.contentSize = self.bounds.size;
        UIImageView *zoomingImageView = [[UIImageView alloc] initWithImage:self.image];
        CGSize imageSize = zoomingImageView.image.size;
        CGFloat imageViewH = self.bounds.size.height;
        if (imageSize.width > 0) {
            imageViewH = self.bounds.size.width * (imageSize.height / imageSize.width);
        }
        zoomingImageView.bounds = CGRectMake(0, 0, self.bounds.size.width, imageViewH);
        zoomingImageView.center = _zoomingScrollView.center;
        zoomingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _zoomingImageView = zoomingImageView;
        [_zoomingScrollView addSubview:zoomingImageView];
        [self addSubview:_zoomingScrollView];
    }
}




#pragma mark - 设置imageView内容
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder{
    //1.添加加载视图
   ZWWaitingView *waitingView = [[ZWWaitingView alloc]init];
    waitingView.bounds = CGRectMake(0, 0, 80, 80);
    waitingView.clipsToBounds = YES;
    waitingView.layer.cornerRadius = 40;
    //默认饼形加载视图
    waitingView.mode = ZWWaitingViewModePieDiagram;
    _waitingView = waitingView;
    [self addSubview:waitingView];
    
//    __weak typeof(self) imageViewWeak = self;
    __weak ZWBrowserImageView *imageViewWeak = self;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        //设置进度,调用setProgress方法
        imageViewWeak.progress = (CGFloat)receivedSize / expectedSize;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //加载完成移除waitingView
        [_waitingView removeFromSuperview];
        
        if(error){//图片加载失败
            UILabel *label = [[UILabel alloc] init];
            label.bounds = CGRectMake(0, 0, 160, 30);
            label.center = CGPointMake(imageViewWeak.bounds.size.width * 0.5, imageViewWeak.bounds.size.height * 0.5);
            label.text = @"图片加载失败";
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            label.layer.cornerRadius = 5;
            label.clipsToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            [imageViewWeak addSubview:label];
        }else{//图片加载成功
            _scrollImageView.image = image;
            //加载成功，调用layoutSubviews方法
            [_scrollImageView setNeedsDisplay];
        }
    }];
}






#pragma mark - 对外提供的方法 public
//双击点击事件
- (void)doubleTapToZommWithScale:(CGFloat)scale{
    [self prepareForImageViewScaling];
    [UIView animateWithDuration:0.5 animations:^{
        [self zoomWithScale:scale];
    } completion:^(BOOL finished) {
        //动画完成，如果scale为1，则移除zoomingScrollView和zoomingImageView
        if (scale == 1) {
            [self clear];
        }
    }];
}
/**
 清除缩放
 */
-(void)eliminateScale{
    [self clear];
    _totalScale = 1.0;
}





/**
 移除zoomingScrollView和zoomingImageView
 */
- (void)clear
{
    [_zoomingScrollView removeFromSuperview];
    _zoomingScrollView = nil;
    _zoomingImageView = nil;
}

/**
 是否处于缩放状态
 */
-(BOOL)isScaled{
    //如果totalScale不等于1.0就处于缩放状态
    return 1.0 != _totalScale;
}

//设置图片waitingView的加载进度
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    _waitingView.progress = progress;
}


@end
