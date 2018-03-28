//
//  XYVLCPlayer.h
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/22.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileVLCKit/MobileVLCKit.h>

@interface XYVLCPlayer : NSObject

+ (instancetype)sharedPlayer;

/** 快进快退时间 */
@property (nonatomic, assign) int fastTime;

/** 播放时间 */
@property (nonatomic, assign) int time;

/** 当前播放时间 */
@property (nonatomic, copy, readonly) NSString *currentTimeText;

/** 总时长 */
@property (nonatomic, copy, readonly) NSString *totalTimeText;

/** 当前播放时间 */
@property (nonatomic, strong, readonly) NSNumber *currentTime;

/** 总时长 */
@property (nonatomic, assign, readonly) CGFloat totalTime;

/** 媒体位置 */
@property (nonatomic, strong) NSURL *mediaURL;

/** 承载视图 */
@property (nonatomic, copy) id mediaView;

/** 时间改变 */
@property (nonatomic, copy)void(^playTime)(NSString *playTime);

@property (nonatomic, strong) NSMutableArray *mediaArray;
/** 播放 */
- (void)play;

/** 暂停 */
- (void)pause;

/** 停止 */
- (void)stop;

/** 播放状态 */
@property (nonatomic, assign, readonly) BOOL playing;


@end
