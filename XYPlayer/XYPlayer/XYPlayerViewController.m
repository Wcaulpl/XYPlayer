
//
//  XYPlayerViewController.m
//  XYPlayer
//
//  Created by Wcaulpl on 2018/3/5.
//  Copyright © 2018年 Wcaulpl. All rights reserved.
//

#import "XYPlayerViewController.h"
#import "XYVLCPlayer.h"
#import "XYPlayer.h"

@interface XYPlayerViewController ()
//@property(nonatomic, weak) XYPlayerView *playerView;
@end

@implementation XYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
//
//    [self.view addSubview: self.playerView =  [XYPlayerView sharedPlayerView]];
//    self.playerView.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
//    self.playerView.mediaURL = [NSURL fileURLWithPath:self.model.videoPath];
    XYPlayerView *playerView = [XYPlayerView sharedPlayerView];
    playerView.frame = CGRectMake(0, 0, ScreenHeight, ScreenWidth);
    [self.view addSubview:playerView];
    playerView.mediaURL = [NSURL fileURLWithPath:self.model.videoPath];
    playerView.mediaName = _model.videoName;
    self.view.transform = CGAffineTransformMakeRotation(M_PI*2); // 旋转90°
    
    __weak typeof(self) weakSelf = self;
    playerView.back = ^{
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    };
    
//    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenHeight, ScreenWidth)];
//    [self.view addSubview:backView];
//
//    UIView *ne = UIView.new;
//    [backView addSubview:ne];
//    [ne mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.top.bottom.equalTo(backView);
//    }];
//    [XYVLCPlayer sharedPlayer].mediaView = backView;
//    [XYVLCPlayer sharedPlayer].mediaURL = [NSURL fileURLWithPath:self.model.videoPath];
//    [XYVLCPlayer sharedPlayer].playTime = ^(NSString *playTime) {
//        NSLog(@"%@", playTime);
//    };
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[XYVLCPlayer sharedPlayer] stop];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// 如果需要横屏的时候，一定要重写这个方法并返回NO
- (BOOL)prefersStatusBarHidden {
    return NO;
}

// 支持设备自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}

/**
 *  设置特殊的界面支持的方向,这里特殊界面只支持Home在右侧的情况
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
