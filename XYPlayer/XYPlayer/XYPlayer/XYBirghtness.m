//
//  MPBirghtness.m
//  MobliePlayer
//
//  Created by zyyt on 17/4/10.
//  Copyright © 2017年 conglei. All rights reserved.
//

#import "XYBirghtness.h"
#import "XYPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <dispatch/dispatch.h>

@interface XYBirghtness ()

@property (nonatomic, strong) UIImageView		*backImage;
@property (nonatomic, strong) UILabel			*title;
@property (nonatomic, strong) UILabel			*bottomTitle;
@property (nonatomic, strong) UIView			*longView;
@property (nonatomic, strong) NSMutableArray	*tipArray;
@property (nonatomic, assign) BOOL				orientationDidChange;
@end

@implementation XYBirghtness

+ (instancetype)sharedBrightnessView{
    static XYBirghtness *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XYBirghtness alloc] init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.bounds = CGRectMake(0 , 0 , 155, 155);
        self.layer.cornerRadius  = 10;
        self.layer.masksToBounds = YES;
        
        // 使用UIToolbar实现毛玻璃效果，简单粗暴，支持iOS7+
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.alpha = 0.97;
        [self addSubview:toolbar];
        [self createTips];
        [self addNotification];
        [self addObserver];
        
        self.alpha = 0.0;
    }
    return self;
}

// 创建 Tips
- (void)createTips {
    
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat tipW = (self.longView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateLongView:[UIScreen mainScreen].brightness];
}

#pragma makr - 通知 KVO
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)   name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}
- (void)addObserver {
    
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}
//亮度改变
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat sound = [change[@"new"] floatValue];
    self.isVolume = NO;
    [self changeVB];
    [self updateLongView:sound];
    
}
//音量改变
- (void)volumeChanged:(NSNotification *)notification{
    float volume =[[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    NSLog(@"%f",volume);
    if (volume <= 0) {
        [self setMute];
        return;
    }
    self.isVolume = YES;
    [self changeVB];
    [self updateLongView:volume];
}
- (void)updateLayer:(NSNotification *)notify {
    self.orientationDidChange = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Methond
- (void)changeVB{
    if (self.isVolume) {
        self.backImage.image        =XYPlayerImage(@"volume");
        self.title.text          = @"音量";
    }else{
        self.backImage.image        = XYPlayerImage(@"brightness");
        self.title.text          = @"亮度";
    }
    self.longView.hidden = NO;
    self.bottomTitle.hidden = YES;
    [self appearSoundView];
}

- (void)setMute{
    self.backImage.image = XYPlayerImage(@"mute");
    self.title.text = @"音量";
    self.longView.hidden = YES;
    self.bottomTitle.hidden = NO;
    [self appearSoundView];
}
- (void)appearSoundView {
        if (self.alpha == 0.0) {
        self.orientationDidChange = NO;
        self.alpha = 1.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disAppearSoundView];
        });
    }
}
- (void)disAppearSoundView {
    
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        }];
    }
}
#pragma mark - Update View

- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);
}
- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 懒加载

- (UIImageView *)backImage{
    if (!_backImage) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
        [self addSubview:imgView];
        _backImage = imgView;
    }
    return _backImage;
}
- (UILabel *)title{
    if (!_title) {
        UILabel *title      = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        title.font          = [UIFont boldSystemFontOfSize:16];
        title.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        _title = title;
    }
    return _title;
}
- (UIView *)longView{
    if (!_longView) {
        UIView *longView         = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        [self addSubview:longView];
        _longView = longView;
    }
    return _longView;
}
- (UILabel *)bottomTitle{
    if (!_bottomTitle) {
        _bottomTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.bounds.size.width, 30)];
        _bottomTitle.font          = [UIFont boldSystemFontOfSize:12];
        _bottomTitle.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _bottomTitle.textAlignment = NSTextAlignmentCenter;
        self.bottomTitle.text    = @"静音";
        [self addSubview:_bottomTitle];
    }
    return _bottomTitle;
}

@end







