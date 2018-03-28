//
//  XYPlayerControlView.m
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/5.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import "XYPlayerControlView.h"
#import "XYPlayer.h"
#import "XYFastView.h"
#import "ASValueTrackingSlider.h"

static const CGFloat XYPlayerAnimationTimeInterval             = 7.0f;
static const CGFloat XYPlayerControlBarAutoFadeOutTimeInterval = 0.35f;

@interface XYPlayerControlView () <UIGestureRecognizerDelegate>

/** 标题 */
@property (nonatomic, weak) UILabel                 *titleLabel;
/** 开始播放按钮 */
@property (nonatomic, weak) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, weak) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, weak) UILabel                 *totalTimeLabel;
/** 全屏按钮 */
@property (nonatomic, weak) UIButton                *fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, weak) UIButton                *lockBtn;
/** 返回按钮*/
@property (nonatomic, weak) UIButton                *backBtn;
/** bottomView*/
@property (nonatomic, weak) UIImageView             *bottomImageView;
/** topView */
@property (nonatomic, weak) UIImageView             *topImageView;
/** 快进快退View*/
@property (nonatomic, weak) XYFastView              *fastView;
/** 滑竿 */
@property (nonatomic, strong) ASValueTrackingSlider   *videoSlider;
/** 占位图 */
@property (nonatomic, weak) UIImageView             *placeholderImageView;
/** 控制层消失时候在底部显示的播放进度progress */
@property (nonatomic, weak) UIProgressView          *bottomProgressView;

/** 滑杆 */
@property(nonatomic, strong) UISlider *volumeViewSlider;

/** 用来保存快进的总时长 */
@property(nonatomic, assign) CGFloat sumTime;

/** 显示控制层 */
@property (nonatomic, assign, getter=isShowing) BOOL  showing;
/** 是否拖拽slider控制播放进度 */
@property (nonatomic, assign, getter=isDragged) BOOL  dragged;
/** 是否播放结束 */
@property (nonatomic, assign, getter=isPlayEnd) BOOL  playeEnd;

@end

@implementation XYPlayerControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        // 添加子控件的约束
        [self makeSubViewsConstraints];
    
        // 初始化时重置controlView
        [self playerResetControlView];
    
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapGesture.numberOfTapsRequired =1;
        singleTapGesture.numberOfTouchesRequired  =1;
        [self addGestureRecognizer:singleTapGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGesture.numberOfTapsRequired =2;
        doubleTapGesture.numberOfTouchesRequired =1;
        [self addGestureRecognizer:doubleTapGesture];
        //只有当doubleTapGesture识别失败的时候(即识别出这不是双击操作)，singleTapGesture才能开始识别
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    }
    return self;
}

//两个手势分别响应的方法
-(void)handleSingleTap:(UIGestureRecognizer *)sender{
    [self playerShowOrHideControlView];
}

-(void)handleDoubleTap:(UIGestureRecognizer *)sender {
    [self playBtnClick:self.startBtn];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)makeSubViewsConstraints {
    
    [self.placeholderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
//        make.top.equalTo(self.mas_top).offset(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.bottom.equalTo(self.bottomImageView.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing).offset(-3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(63);
    }];

    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-5);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.mas_leading).offset(3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(63);
    }];
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(32);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.topImageView.mas_leading).offset(10);
        make.top.equalTo(self.topImageView.mas_top).offset(3);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.fastView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(80);
        make.center.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.backBtn.mas_trailing).offset(5);
        make.centerY.equalTo(self.backBtn.mas_centerY);
        make.trailing.equalTo(self.mas_trailing).offset(-10);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
        make.centerY.equalTo(self.currentTimeLabel.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    
    [self.bottomProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_offset(0);
        make.bottom.mas_offset(0);
    }];
}


#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        _titleLabel = titleLabel;
        titleLabel.text = @"阿冉冉发展观为人工";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_titleLabel sizeToFit];
        [self.topImageView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn = backBtn;
        [_backBtn setImage:XYPlayerImage(@"back_full") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topImageView addSubview:_backBtn];
    }
    return _backBtn;
}

- (UIImageView *)topImageView {
    if (!_topImageView) {
        UIImageView *topImageView            = [[UIImageView alloc] init];
        _topImageView = topImageView;
        _topImageView.userInteractionEnabled = YES;
        _topImageView.alpha                  = 0;
        _topImageView.image                  = XYPlayerImage(@"top_shadow");
        [self addSubview:_topImageView];
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        UIImageView *bottomImageView            = [[UIImageView alloc] init];
        _bottomImageView = bottomImageView;
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.alpha                  = 0;
        _bottomImageView.image                  = XYPlayerImage(@"bottom_shadow");
        [self addSubview:_bottomImageView];

    }
    return _bottomImageView;
}

- (UIButton *)lockBtn {
    if (!_lockBtn) {
        UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lockBtn = lockBtn;
        [_lockBtn setImage:XYPlayerImage(@"unlock-nor") forState:UIControlStateNormal];
        [_lockBtn setImage:XYPlayerImage(@"lock-nor") forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lockScrrenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_lockBtn];
    }
    return _lockBtn;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn = startBtn;
        [_startBtn setImage:XYPlayerImage(@"play") forState:UIControlStateSelected];
        [_startBtn setImage:XYPlayerImage(@"pause") forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomImageView addSubview:_startBtn];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        UILabel *currentTimeLabel       = [[UILabel alloc] init];
        _currentTimeLabel = currentTimeLabel;
        currentTimeLabel.text = @"ewqe";
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomImageView addSubview:self.currentTimeLabel];
    }
    return _currentTimeLabel;
}

- (ASValueTrackingSlider *)videoSlider {
    if (!_videoSlider) {
        ASValueTrackingSlider *videoSlider = [[ASValueTrackingSlider alloc] init];
        _videoSlider = videoSlider;
        _videoSlider.popUpViewCornerRadius = 0.0;
        _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
        _videoSlider.popUpViewArrowLength = 8;
        
        [_videoSlider setThumbImage:XYPlayerImage(@"slider") forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        // slider开始滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [_videoSlider addGestureRecognizer:sliderTap];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
        panRecognizer.delegate = self;
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelaysTouchesBegan:YES];
        [panRecognizer setDelaysTouchesEnded:YES];
        [panRecognizer setCancelsTouchesInView:YES];
        [_videoSlider addGestureRecognizer:panRecognizer];
        [self.bottomImageView addSubview:_videoSlider];
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        UILabel *totalTimeLabel       = [[UILabel alloc] init];
        totalTimeLabel.text = @"ewqe";
        _totalTimeLabel = totalTimeLabel;
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomImageView addSubview:_totalTimeLabel];
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn = fullScreenBtn;
        [_fullScreenBtn setImage:XYPlayerImage(@"fullscreen") forState:UIControlStateNormal];
        [_fullScreenBtn setImage:XYPlayerImage(@"shrinkscreen") forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomImageView addSubview:_fullScreenBtn];
    }
    return _fullScreenBtn;
}

- (XYFastView *)fastView {
    if (!_fastView) {
        XYFastView *fastView = [[XYFastView alloc] init];
        _fastView = fastView;
        _fastView.backgroundColor = RGBA(0, 0, 0, 0.8);
        _fastView.layer.cornerRadius = 4;
        _fastView.layer.masksToBounds = YES;
        [self addSubview:_fastView];
    }
    return _fastView;
}

- (UIImageView *)placeholderImageView {
    if (!_placeholderImageView) {
        UIImageView *placeholderImageView = [[UIImageView alloc] init];
        _placeholderImageView = placeholderImageView;
        _placeholderImageView.userInteractionEnabled = YES;
        [self addSubview:_placeholderImageView];

    }
    return _placeholderImageView;
}

- (UIProgressView *)bottomProgressView {
    if (!_bottomProgressView) {
        UIProgressView *bottomProgressView    = [[UIProgressView alloc] init];
        _bottomProgressView = bottomProgressView;
        _bottomProgressView.progressTintColor = [UIColor whiteColor];
        _bottomProgressView.trackTintColor    = [UIColor clearColor];
        [self addSubview:_bottomProgressView];
    }
    return _bottomProgressView;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGRect rect = [self thumbRect];
    CGPoint point = [touch locationInView:self.videoSlider];
    if ([touch.view isKindOfClass:[UISlider class]]) { // 如果在滑块上点击就不响应pan手势
        if (point.x <= rect.origin.x + rect.size.width && point.x >= rect.origin.x) {
            return NO;
        }
    }
    return YES;
}

/**
 *  重置控制视图
 */
- (void)playerResetControlView {
    self.videoSlider.value           = 0;
    self.bottomProgressView.progress = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.fastView.alpha             = 0;
    self.backgroundColor             = [UIColor clearColor];
    self.showing                     = NO;
    self.playeEnd                    = NO;
    self.lockBtn.hidden              = NO;
    self.placeholderImageView.alpha  = 1;
    [self hideControlView];
}

- (void)autoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerHideControlView) object:nil];
    [self performSelector:@selector(playerHideControlView) withObject:nil afterDelay:XYPlayerAnimationTimeInterval];
    
    __weak typeof(self) weakSelf = self;
    [XYVLCPlayer sharedPlayer].playTime = ^(NSString *playTime) {
        [weakSelf configuraTimeLabelText:playTime];
    };
}

- (void)configuraTimeLabelText:(NSString *)currTime {
    self.currentTimeLabel.text = currTime;
    self.totalTimeLabel.text = [XYVLCPlayer sharedPlayer].totalTimeText;
    self.videoSlider.value = [XYVLCPlayer sharedPlayer].currentTime.floatValue / [XYVLCPlayer sharedPlayer].totalTime;
    self.bottomProgressView.progress = [XYVLCPlayer sharedPlayer].currentTime.floatValue / [XYVLCPlayer sharedPlayer].totalTime;
}

- (void)playerCancelAutoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

/** 快进 */
- (void)progress:(CGFloat)progress time:(NSString *)time value:(CGFloat)value{
    [self.fastView setProgress:progress time:time value:value];
    self.videoSlider.value = [XYVLCPlayer sharedPlayer].currentTime.floatValue / [XYVLCPlayer sharedPlayer].totalTime;
    self.bottomProgressView.progress = [XYVLCPlayer sharedPlayer].currentTime.floatValue / [XYVLCPlayer sharedPlayer].totalTime;
}

/**
 *  UISlider TapAction
 */
- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        slider.value = tapValue;
        int targetIntvalue = (int)(tapValue * [XYVLCPlayer sharedPlayer].totalTime);
        [XYVLCPlayer sharedPlayer].time = targetIntvalue;
        
    }
    
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

// 不做处理，只是为了滑动slider其他地方不响应其他手势
- (void)panRecognizer:(UIPanGestureRecognizer *)sender {
    
}

- (void)backBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(controlView:backAction:)]) {
        [self.delegate controlView:self backAction:sender];
    }
}

/*
 * 屏幕控制🔐
 */
- (void)lockScrrenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.showing = NO;
    [self playerShowOrHideControlView];
    if ([self.delegate respondsToSelector:@selector(controlView:lockScreenAction:)]) {
        [self.delegate controlView:self lockScreenAction:sender];
    }
}

- (void)playerShowOrHideControlView {
    if (self.isShowing) {
        [self playerHideControlView];
    } else {
        [self playerShowControlView];
    }
}
/**
 *  显示控制层
 */
- (void)playerShowControlView {
    [self playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:XYPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self showControlView];
    } completion:^(BOOL finished) {
        self.showing = YES;
        [self autoFadeOutControlView];
    }];
}

/**
 *  隐藏控制层
 */
- (void)playerHideControlView {
    [self playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:XYPlayerControlBarAutoFadeOutTimeInterval animations:^{
        [self hideControlView];
    } completion:^(BOOL finished) {
        self.showing = NO;
    }];
}

/*
 * 播放暂停按钮
 */
- (void)playBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [XYVLCPlayer sharedPlayer].playing ? [[XYVLCPlayer sharedPlayer] pause] : [[XYVLCPlayer sharedPlayer] play];
}

- (void)fullScreenBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self backBtnClick:self.backBtn];
}

- (void)progressSliderTouchBegan:(ASValueTrackingSlider *)sender {
    [self playerCancelAutoFadeOutControlView];
    self.videoSlider.popUpView.hidden = YES;

}

- (void)progressSliderValueChanged:(ASValueTrackingSlider *)sender {
    int targetIntvalue = (int)(sender.value * [XYVLCPlayer sharedPlayer].totalTime);
    [XYVLCPlayer sharedPlayer].time = targetIntvalue;
}

- (void)progressSliderTouchEnded:(ASValueTrackingSlider *)sender {
    self.showing = YES;
    int targetIntvalue = (int)(sender.value * [XYVLCPlayer sharedPlayer].totalTime);
    [XYVLCPlayer sharedPlayer].time = targetIntvalue;
}

/**
 slider滑块的bounds
 */
- (CGRect)thumbRect {
    return [self.videoSlider thumbRectForBounds:self.videoSlider.bounds
                                      trackRect:[self.videoSlider trackRectForBounds:self.videoSlider.bounds]
                                          value:self.videoSlider.value];
}

- (void)playerPlayDidEnd {
    self.backgroundColor  = RGBA(0, 0, 0, .6);
    // 初始化显示controlView为YES
    self.showing = NO;
    // 延迟隐藏controlView
    [self playerShowControlView];
}


- (void)showControlView {
    self.showing = YES;
    if (self.lockBtn.isSelected) {
        self.topImageView.alpha    = 0;
        self.bottomImageView.alpha = 0;
    } else {
        self.topImageView.alpha    = 1;
        self.bottomImageView.alpha = 1;
    }
    self.backgroundColor           = RGBA(0, 0, 0, 0.3);
    self.lockBtn.alpha             = 1;
    self.bottomProgressView.alpha  = 0;
}

- (void)hideControlView {
    self.showing = NO;
    self.backgroundColor          = RGBA(0, 0, 0, 0);
    self.topImageView.alpha       = self.playeEnd;
    self.bottomImageView.alpha    = 0;
    self.lockBtn.alpha            = 0;
    self.bottomProgressView.alpha = 1;
}

- (void)setTime:(NSNumber *)time {
    _time = time;
    self.currentTimeLabel.text = time.stringValue;
}

- (void)setTotalTime:(NSNumber *)totalTime {
    _totalTime = totalTime;
    self.totalTimeLabel.text = totalTime.stringValue;
}


#pragma mark - 滑竿改变进度

- (void)changePlayTime:(CGFloat)value {
    if (value > 1) {value = 1;}
    if (value < 0) {value = 0;}
    
    [self.bottomProgressView setProgress:value animated:YES];
    [self.videoSlider setValue:value animated:YES];
    self.currentTimeLabel.text = self.time.stringValue;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
