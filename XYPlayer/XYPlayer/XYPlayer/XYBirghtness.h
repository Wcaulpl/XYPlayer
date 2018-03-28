//
//  MPBirghtness.h
//  MobliePlayer
//
//  Created by zyyt on 17/4/10.
//  Copyright © 2017年 conglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYBirghtness : UIView

/** 是否是音量 */
@property (assign,nonatomic) BOOL isVolume;

+ (instancetype)sharedBrightnessView;

@end
