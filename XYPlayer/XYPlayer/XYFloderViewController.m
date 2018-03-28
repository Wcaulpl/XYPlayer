//
//  MPFloderViewController.m
//  MobliePlayer
//
//  Created by zyyt on 17/4/24.
//  Copyright © 2017年 conglei. All rights reserved.
//

#import "XYFloderViewController.h"
#import "XYPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

static int pass = 0;

@interface XYFloderViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong,nonatomic) UITableView *tableView;
/** 数据 */
@property (weak, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) YYThreadSafeArray *datas;

@property (nonatomic, weak) UILabel *messagelabel;

@property (nonatomic, assign) BOOL showInView;

@property (nonatomic, assign) BOOL isShowing;


@end

@implementation XYFloderViewController



- (YYThreadSafeArray *)datas {
    if (!_datas) {
        _datas = [YYThreadSafeArray array];
    }
    return _datas;
}

- (UILabel *)messagelabel {
    if (!_messagelabel) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.text = @"手机没有资源，请通过iTunes导入文件到APP下";
        label.center = self.view.center;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        [self.view addSubview:self.messagelabel = label];
    }
    return _messagelabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"iTunesCell"];
        //        tableView.estimatedRowHeight = 79.0f;
        //        tableView.rowHeight = UITableViewAutomaticDimension;
        [self.view addSubview:self.tableView=tableView];
        
    }
    return _tableView;
}

- (void)loadView {
    [super loadView];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    __weak typeof(self) weakSelf = self;
    [self.messagelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.centerY.equalTo(weakSelf.view.mas_centerY);
        make.left.equalTo(weakSelf.view.mas_left).offset(30);
        make.right.equalTo(weakSelf.view.mas_right).offset(-30);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top);
        make.bottom.equalTo(weakSelf.view.mas_bottom);
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// 页面消失时候
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    [self.playerView resetPlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.title = @"本地视频";
    self.view.backgroundColor = [UIColor grayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:(UIBarButtonItemStylePlain) target:self action:@selector(clickLeftBarDelete:)];
    
    [self getiTunesVideo];
    
    // 这里
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:@"com.refreshiTunesUI.notification" object:nil];
    
}

- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    // 这里设置横竖屏不同颜色的statusbar
//    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
//    if (duration == UIDeviceOrientationPortrait
//        || duration == UIDeviceOrientationPortraitUpsideDown) {
//        return UIStatusBarStyleDefault;
//    }
//    return UIStatusBarStyleLightContent;
//}

//- (BOOL)prefersStatusBarHidden {
//    return ZFPlayerShared.isStatusBarHidden;
//}

- (void)clickLeftBarDelete:(UIBarButtonItem *)barButtonItem {
    
    if ([self isHeadsetPluggedIn]) {
        pass++;
        if (self.isShowing) {
            if (self.tableView.hidden) {
                self.tableView.hidden = NO;
            }
            self.dataArray = [XYVLCPlayer sharedPlayer].mediaArray;
            [self.tableView reloadData];
        }
    }
    
    if (self.isShowing && pass > 5) {
        pass = 0;
        self.isShowing = NO;
        self.dataArray = self.datas;
        [self.tableView reloadData];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (pass == 3 && !self.isShowing) {
        self.isShowing = YES;
    }
}

- (void)getiTunesVideo { //根据数据有无，判断控件的显示
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:[VideoModel modelArrayWithDicArray:[FileWatcher shared].dataSource]];
        self.dataArray = self.datas;
        if (self.datas.count > 0) {
            self.messagelabel.hidden = YES;
            self.tableView.hidden = NO;
            
            [self.tableView reloadData];
        } else {
            self.messagelabel.hidden = NO;
            self.tableView.hidden = YES;
        }
    });
}

- (void)refreshUI {
    [self getiTunesVideo];
}

#pragma mark 设置cell

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iTunesCell" forIndexPath:indexPath];
    VideoModel *model = self.dataArray[indexPath.row];
    cell.imageView.image = [UIImage imageWithContentsOfFile:model.videoImgPath];
    cell.textLabel.text = model.videoName;
//    cell.detailTextLabel.text = [NSString byteUnitConvert:model.videoSize];
    return cell;
}

//- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
//    if (!self.showInView) {
//        iTunesCell *cell = (iTunesCell *)longPress.view;
//        cell.model.select = YES;
//        self.showInView = YES;
//        [self.tableView reloadData];
//    }
//
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    VideoModel *model = self.dataArray[indexPath.row];
    XYPlayerViewController *player = [[XYPlayerViewController alloc] init];
    player.model = model;
    [self presentViewController:player animated:NO completion:nil];
    if (pass == 3 && !self.isShowing) {
        self.isShowing = YES;
    }
}

//设置编辑风格EditingStyle
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing)//----通过表视图是否处于编辑状态来选择是左滑删除，还是多选删除。
    {
        //当表视图处于没有未编辑状态时选择多选删除
        return UITableViewCellEditingStyleDelete| UITableViewCellEditingStyleInsert;
    }
    else
    {
        //当表视图处于没有未编辑状态时选择左滑删除
        return UITableViewCellEditingStyleDelete;
    }
    
}
//根据不同的editingstyle执行数据删除操作（点击左滑删除按钮的执行的方法）
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        VideoModel *model = self.dataArray[indexPath.row];
        [[FileWatcher shared] deleteiTunesVideo:@[[model dictionaryFromModel]]];
        [_dataArray removeObjectAtIndex:indexPath.row];
        // Delete the row from the data source.
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if(editingStyle == (UITableViewCellEditingStyleDelete| UITableViewCellEditingStyleInsert))
    {
        
    }
    
}
//修改左滑删除按钮的title
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
