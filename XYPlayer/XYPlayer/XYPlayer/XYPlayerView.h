//
//  XYPlayerView.h
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/7.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPlayerControlView.h"

@interface XYPlayerView : UIView

+ (instancetype)sharedPlayerView;

/** 位置 */
@property (strong,nonatomic) NSURL *mediaURL;

@property (copy,nonatomic) NSString *mediaName;

@property (nonatomic, copy) void(^back)(void);

@end
