//
//  XYPlayerControlView.h
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/5.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPlayerControlDelagate.h"
#import "XYVLCPlayer.h"


@interface XYPlayerControlView : UIView

@property (nonatomic, weak) id<XYPlayerControlDelagate> delegate;

@property (NS_NONATOMIC_IOSONLY, strong) NSNumber *time;

@property (NS_NONATOMIC_IOSONLY, strong) NSNumber *totalTime;

@property (NS_NONATOMIC_IOSONLY, copy) NSString *title;

- (void)playerShowOrHideControlView;

/** 快进 */
- (void)progress:(CGFloat)progress time:(NSString *)time value:(CGFloat)value;


@end
