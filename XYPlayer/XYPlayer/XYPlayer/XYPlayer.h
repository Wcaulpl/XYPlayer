//
//  XYPlayer.h
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/5.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

// 屏幕的宽
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
// 颜色值RGB
#define RGBA(r,g,b,a)                       [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

// 图片路径
#define XYPlayerSrcName(file)               [@"XYPlayer.bundle" stringByAppendingPathComponent:file]

#define XYPlayerFrameworkSrcName(file)      [@"Frameworks/XYPlayer.framework/XYPlayer.bundle" stringByAppendingPathComponent:file]

#define XYPlayerImage(file)                 [UIImage imageNamed:XYPlayerSrcName(file)] ? :[UIImage imageNamed:XYPlayerFrameworkSrcName(file)]

#define CLNotificationCenter [NSNotificationCenter defaultCenter]

#import "XYPlayerView.h"
#import <Masonry/Masonry.h>


