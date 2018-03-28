//
//  XYVLCPlayer.m
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/22.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import "XYVLCPlayer.h"

@interface XYVLCPlayer ()<VLCMediaPlayerDelegate>
/**
 *  VCL对象
 */
@property (nonatomic, strong) VLCMediaPlayer *player;

@end

@implementation XYVLCPlayer

+ (instancetype)sharedPlayer {
    static XYVLCPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[XYVLCPlayer alloc] init];
    });
    return player;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _player = [[VLCMediaPlayer alloc] init];
        _player.delegate = self;

    }
    return self;
}

- (void)setFastTime:(int)fastTime {
    if (time > 0) {
        [self.player jumpForward:abs(fastTime)]; // 快进播放
    } else {
        [self.player jumpBackward:abs(fastTime)]; // 快退播放
    }
}

- (void)setTime:(int)time {
    VLCTime *targetTime = [[VLCTime alloc] initWithInt:time];
    self.player.time = targetTime;
    if (!self.playing) {
        [self play];
    }
}

- (NSString *)currentTimeText {
    return self.player.time.stringValue;
}

- (NSNumber *)currentTime {
    return self.player.time.value;
}

- (CGFloat)totalTime {
    return self.player.media.length.value.floatValue;
}

- (NSString *)totalTimeText {
    return self.player.media.length.stringValue;
}

- (void)setMediaURL:(NSURL *)mediaURL {
    _mediaURL = mediaURL;
    self.player.media = [VLCMedia mediaWithURL:_mediaURL];
    if (self.mediaView) {
        [self play];
    }
}

- (void)setMediaView:(id)mediaView {
    _mediaView = mediaView;
    self.player.drawable = mediaView;
    if (self.mediaURL) {
        [self play];
    }
}

#pragma mark 播放状态设置

- (BOOL)playing {
    return self.player.playing;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player stop];
}

#pragma mark VLCMediaPlayerDelegate
// 播放状态改变的回调
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    /**
     *  VLCMediaPlayerStateStopped,        //< Player has stopped
     VLCMediaPlayerStateOpening,        //< Stream is opening
     VLCMediaPlayerStateBuffering,      //< Stream is buffering
     VLCMediaPlayerStateEnded,          //< Stream has ended
     VLCMediaPlayerStateError,          //< Player has generated an error
     VLCMediaPlayerStatePlaying,        //< Stream is playing
     VLCMediaPlayerStatePaused          //< Stream is paused
     */
    NSLog(@"mediaPlayerStateChanged");
    NSLog(@"状态：%ld",(long)_player.state);
    switch ((int)_player.state) {
        case VLCMediaPlayerStateStopped: // 停止播放（播放完毕或手动stop）
            [self.player stop];
            break;
        case VLCMediaPlayerStateBuffering: // 播放中缓冲状态
            break;
        case VLCMediaPlayerStatePlaying: // 被暂停后开始播放
            break;
        case VLCMediaPlayerStatePaused:  // 播放后被暂停
            break;
    }
}

// 播放时间改变的回调
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    if (self.currentTime.floatValue == self.totalTime) {
        [self stop];
    } else if (!self.playing) {
        [self play];
    }
    if (self.playTime) {
        NSLog(@"%@", [(VLCMediaPlayer *)aNotification.object time].stringValue);
        self.playTime([(VLCMediaPlayer *)aNotification.object time].stringValue);
    }
}



@end
