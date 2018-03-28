//
//  XYPlayerControlDelagate.h
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/6.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#ifndef XYPlayerControlDelagate_h
#define XYPlayerControlDelagate_h


#endif /* XYPlayerControlDelagate_h */
@class XYPlayerControlView;

@protocol XYPlayerControlDelagate <NSObject>

@optional
/** 返回按钮事件 */
- (void)controlView:(XYPlayerControlView *)controlView backAction:(UIButton *)sender;
/** 播放按钮事件 */
- (void)controlView:(XYPlayerControlView *)controlView playAction:(UIButton *)sender;
/** 全屏按钮事件 */
- (void)controlView:(XYPlayerControlView *)controlView fullScreenAction:(UIButton *)sender;
/** 锁定屏幕方向按钮时间 */
- (void)controlView:(XYPlayerControlView *)controlView lockScreenAction:(UIButton *)sender;
/** 重播按钮事件 */
- (void)controlView:(XYPlayerControlView *)controlView repeatPlayAction:(UIButton *)sender;
/** 中间播放按钮事件 */
- (void)controlView:(XYPlayerControlView *)controlView cneterPlayAction:(UIButton *)sender;
/** 加载失败按钮事件 */
- (void)controlView:(XYPlayerControlView *)controlView failAction:(UIButton *)sender;
/** slider的点击事件（点击slider控制进度） */
- (void)controlView:(XYPlayerControlView *)controlView progressSliderTap:(CGFloat)value;
/** 开始触摸slider */
- (void)controlView:(XYPlayerControlView *)controlView progressSliderTouchBegan:(UISlider *)slider;
/** slider触摸中 */
- (void)controlView:(XYPlayerControlView *)controlView progressSliderValueChanged:(UISlider *)slider;
/** slider触摸结束 */
- (void)controlView:(XYPlayerControlView *)controlView progressSliderTouchEnded:(UISlider *)slider;
/** 控制层即将显示 */
- (void)controlViewWillShow:(XYPlayerControlView *)controlView;
/** 控制层即将隐藏 */
- (void)controlViewWillHidden:(XYPlayerControlView *)controlView;
/** 滑动屏幕控制进度 */

//- (void)controlView:(XYPlayerControlView *)controlView progressSliderTouchBegan:(UISlider *)slider;

@end
