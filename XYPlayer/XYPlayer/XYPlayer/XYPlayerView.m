//
//  XYPlayerView.m
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/7.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import "XYPlayerView.h"
#import "XYPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "XYBirghtness.h"
#import "XYPanGestureRecognizer.h"

@interface XYPlayerView () <VLCMediaPlayerDelegate, XYPlayerControlDelagate,UIGestureRecognizerDelegate,XYPanGestureRecognizerDelegate>

/** 屏幕锁*/
@property (nonatomic, assign) BOOL isLocked;

@property(strong, nonatomic) XYPlayerControlView *controlView;

@property(strong, nonatomic) UIView *mediaView;
/** 亮度 */
@property (strong,nonatomic) XYBirghtness *birghtness;

/** 滑杆 */
@property (nonatomic, strong) UISlider *volumeViewSlider;

/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat sumTime;

@end


@implementation XYPlayerView

+ (instancetype)sharedPlayerView {
    static XYPlayerView *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[XYPlayerView alloc] init];
    });
    return player;
}


- (UIView *)mediaView {
    if (!_mediaView) {
        UIView *mediaView = [[UIView alloc] init];
        [self addSubview:self.mediaView=mediaView];
        [mediaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(self);
            make.center.equalTo(self);
        }];
    }
    return _mediaView;
}

- (XYPlayerControlView *)controlView {
    if (!_controlView) {
        XYPlayerControlView *controlView = [[XYPlayerControlView alloc] init];
        controlView.delegate = self;
        [self addSubview:self.controlView=controlView];
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(self);
            make.center.equalTo(self);
        }];
    }
    return _controlView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        XYPanGestureRecognizer *panRecognizer = [XYPanGestureRecognizer panGestureRecognizer];
        panRecognizer.delegate = self;
        panRecognizer.panDelegate = self;
        [self addGestureRecognizer:panRecognizer];
        
        XYBirghtness * birghtness = [XYBirghtness sharedBrightnessView];
        _birghtness = birghtness;
        [birghtness mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(155));
            make.height.equalTo(@(155));
            make.center.equalTo([UIApplication sharedApplication].keyWindow);
        }];
    }
    return self;
}

- (void)willConfigureSubViews {
    [self.controlView playerShowOrHideControlView];
    [self addNotification];
    [self bringSubviewToFront:self.controlView];
    [self configureVolume];
}

#pragma mark - view init
- (void)addNotification{
    // app从后台进入前台都会调用这个方法
    [CLNotificationCenter addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    // 添加检测app进入后台的观察者
    [CLNotificationCenter addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationWillResignActiveNotification object:nil];
    //耳机插入拔掉通知
    [CLNotificationCenter addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    
}

//app前后台切换通知
- (void)applicationBecomeActive{
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
}
- (void)applicationEnterBackground{
    
}
//app耳机插入通知
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{
            // 耳机拔掉
            // 拔掉耳机继续播放
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

#pragma mark - UIPanGestureRecognizer手势方法
/** pan水平移动的方法 */
- (void)horizontalMoved:(CGFloat)value {
    self.sumTime = self.sumTime + value;
    //    移动的时常
    CGFloat play = self.sumTime/[XYVLCPlayer sharedPlayer].totalTime;
    if (play > 1) { play = 1;}
    if (play < 0) { play = 0;}
    [self changePlayTime:play];
    
    [self.controlView progress:play time:[self durationStringWithTime:play * [XYVLCPlayer sharedPlayer].totalTime] value:value];
}

/** 根据时长求出字符串 */
- (NSString *)durationStringWithTime:(int)time {
    VLCTime *timer = [VLCTime timeWithInt:time];
    return timer.stringValue;
}

/** pan垂直移动的方法 */
- (void)verticalMoved:(CGFloat)value {
    self.birghtness.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

/** 获取系统音量 */
- (void)configureVolume {
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 100, 100)];
    volumeView.hidden = NO;
    [self addSubview:volumeView];
    _volumeViewSlider = nil;
    //去掉提示框
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            [_volumeViewSlider setFrame:CGRectMake(-1000, -1000, 10, 10)];
            _volumeViewSlider = (UISlider *)view;
            
            break;
        }
    }
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
}

#pragma mark - 滑竿改变进度
- (void)changePlayTime:(CGFloat)value{
    if (value > 1) { value = 1;}
    if (value < 0) { value = 0;}
}
- (void)playWithTime:(CGFloat)value{
    int targetIntvalue = (int)(value * [XYVLCPlayer sharedPlayer].totalTime);
    [XYVLCPlayer sharedPlayer].time = targetIntvalue;
}

- (void)setMediaURL:(NSURL *)mediaURL {
    _mediaURL = mediaURL;
    [XYVLCPlayer sharedPlayer].mediaView = self.mediaView;
    [XYVLCPlayer sharedPlayer].mediaURL = _mediaURL;
    [self willConfigureSubViews];
}

- (void)setMediaName:(NSString *)mediaName {
    _mediaName = mediaName;
    self.controlView.title = mediaName;
}

//横向移动
- (void)panHorizontalMoved:(PanMoved)moved position:(CGFloat)position{
    if (self.isLocked) {
        return;
    }
    switch (moved) {
        case PanBeganMoved:
            NSLog(@"66666666666666666666::::::%@",[XYVLCPlayer sharedPlayer].currentTimeText);
            self.sumTime = [XYVLCPlayer sharedPlayer].currentTime.intValue; //self.mediaPlayer.time.intValue;
            break;
        case PanChangeMoved:
            [self horizontalMoved:position];
            break;
        case PanEndMoved:{
            CGFloat play = self.sumTime/[XYVLCPlayer sharedPlayer].totalTime;
            [self playWithTime:play];
            self.sumTime = 0;
        }break;
        default:
            break;
    }
}
//纵向移动
-(void)panVerticalMovedVolum:(PanMoved)moved position:(CGFloat)position isVolume:(BOOL)isVolume{
    if (self.isLocked) {
        return;
    }
    switch (moved) {
        case PanBeganMoved:
            self.birghtness.isVolume = isVolume;
            break;
        case PanChangeMoved:
            [self verticalMoved:position];
            break;
        case PanEndMoved:
            self.birghtness.isVolume = NO;
            break;
        default:
            break;
    }
}

#pragma mark XYPlayerControlDelagate

- (void)controlView:(XYPlayerControlView *)controlView backAction:(UIButton *)sender {
    if (self.back) {
        self.back();
    }
}

- (void)controlView:(XYPlayerControlView *)controlView lockScreenAction:(UIButton *)sender {
    self.isLocked = sender.selected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
