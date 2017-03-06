//
//  ZWPhotoBrowser.m
//  ZWPhotoBrowserDemo
//
//  Created by 郑亚伟 on 2017/2/10.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "ZWBrowserImageView.h"
#import "ZWPhototBrowserConfig.h"


@interface ZWPhotoBrowser ()<UIAlertViewDelegate>
@property(nonatomic,strong)UIScrollView *scrollView;
//当前的ZWBrowserImageView是否加载过图像
@property(nonatomic,assign)BOOL hasShowedFirstView;
//图片张数展示
@property(nonatomic,strong)UILabel *indexLabel;

//????????
@property(nonatomic,strong)UIActivityIndicatorView *indicatorView;

/**
 是否将要离开图片展示界面
 */
@property(nonatomic,assign)BOOL willDisappear;

@end

@implementation ZWPhotoBrowser

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZWPhotoBrowserBackgrounColor;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
        longPress.minimumPressDuration = 1.5;
        longPress.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:longPress];
    }
    return self;
}
- (void)dealloc{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}
/**
 系统方法
 */
- (void)didMoveToSuperview{
    [self setupScrollView];
    [self setupToolView];
}


/**
 layoutSubviews方法
 注意:为了让图片在滚动的时候显示间距的特殊布局做法。
 scrollView宽度左右两边各加10 ， scrollView的子视图左右两边也各加10，contentSize依然同常规的一样，然后scrollView按页滚动便实现中间有分割线的效果
 */
- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect rect = self.bounds;
    rect.size.width += ZWPhotoBrowserImageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - ZWPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof ZWBrowserImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        CGFloat x = ZWPhotoBrowserImageViewMargin + idx * (ZWPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    //第一张图展示的时候，还要展示首张图片的动画效果
    if(!_hasShowedFirstView){
        [self showFirstImage];
    }
    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
}

/**
 设置scrollView
 */
- (void)setupScrollView{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    for (NSInteger i = 0; i < self.imageCount; i++) {
        ZWBrowserImageView *imageView = [[ZWBrowserImageView alloc]init];
        imageView.tag = i;
        //添加单击事件
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        //添加双击事件
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        //解决手势冲突（单击和双击手势冲突）
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [_scrollView addSubview:imageView];
    }
    //加载当前图片
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
}
/**
 加载当前图片
 */
- (void)setupImageOfImageViewForIndex:(NSInteger)index{
    ZWBrowserImageView *imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    //当前的ZWBrowserImageView加载过图像,后续不再执行，否者调用ZWBrowserImageView中加载图像的方法
    if (imageView.hasLoadedImage) {return;}
    if ([self highQualityImageURLForIndex:index]) {//设置了高清图代理
        //在这里设置占位图
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:self.placeholderImage];
        
    }else{//未设置高清图时，显示原来的小图像
        imageView.image = [self smallImageForIndex:index];
        //NSLog(@"%@",imageView.image);
    }
    imageView.hasLoadedImage = YES;
    
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}
- (UIImage *)smallImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:smallImageForIndex:)]) {
        return [self.delegate photoBrowser:self smallImageForIndex:index];
    }
    return nil;
}


/**
 设置图片展示张数的label和保存按钮
 */
- (void)setupToolView{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
    if (self.imageCount > 1) {
        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
    }
    _indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
}



#pragma mark - 击手势事件
//图片单击事件
- (void)photoClick:(UITapGestureRecognizer *)recognizer{
    _scrollView.hidden = YES;
    _willDisappear = YES;
    ZWBrowserImageView *currentImageView = (ZWBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    UIView *sourceView = nil;
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:currentIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else {
        sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    }
   
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    // 防止 因imageview的image加载失败 导致 崩溃
    if (!currentImageView.image) {
        h = self.bounds.size.height;
    }
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];
    
//    _saveBtn.hidden = YES;
    
    [UIView animateWithDuration:ZWPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
        _indexLabel.alpha = 0.1;
    } completion:^(BOOL finished) {
        //动画完成后Window不用管它
        [self removeFromSuperview];
    }];
    
}
//图片双击事件
- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer{
    ZWBrowserImageView *imageView = (ZWBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    [imageView doubleTapToZommWithScale:scale];
}
//自身View长按手势事件
- (void)longPressGesture:(UILongPressGestureRecognizer *)longPressGesture{
    //避免长按手势执行两次
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按手势事件");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否保存图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert show];
    }
}

#pragma mark -UIAlertViewDelegate代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
        UIImageView *currentImageView = _scrollView.subviews[index];
        
        UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        indicator.center = self.center;
        _indicatorView = indicator;
        [[UIApplication sharedApplication].keyWindow addSubview:indicator];
        [indicator startAnimating];
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = ZWPhotoBrowserSaveImageFailText;
    }   else {
        label.text = ZWPhotoBrowserSaveImageSuccessText;
    }
    //removeFromSuperview是系统方法
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}


/**
 展示的第一张图片要做特殊的处理
 */
- (void)showFirstImage{
    
    UIView *sourceView = nil;
    if ([self.sourceImagesContainerView isKindOfClass:UICollectionView.class]) {//容器视图为UICollectionView
        UICollectionView *view = (UICollectionView *)self.sourceImagesContainerView;
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentImageIndex inSection:0];
        sourceView = [view cellForItemAtIndexPath:path];
    }else{//容器视图为一般的UIView
        sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    }
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self smallImageForIndex:self.currentImageIndex];
    [self addSubview:tempView];
    
    
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    //执行动画之前先隐藏scrollView，动画执行完成后显示scrollView
    _scrollView.hidden = YES;
    [UIView animateWithDuration:ZWPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFirstView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}

#pragma mark - scrollview代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if (x - index *self.bounds.size.width > margin || x - index * self.bounds.size.width < -margin) {
        ZWBrowserImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    //设置UILabel显示内容
    if (!_willDisappear) {
        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    }
    
    //滑动的时候加载下一张图片
    [self setupImageOfImageViewForIndex:index];
}


#pragma mark - public
//点击进入的时候是先显示window，再执行动画效果
- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        ZWBrowserImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[ZWBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}


@end
