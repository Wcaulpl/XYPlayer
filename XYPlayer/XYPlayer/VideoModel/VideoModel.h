//
//  VideoModel.h
//  GetLocalVideo
//
//  Created by Charles.Yao on 2016/11/11.
//  Copyright © 2016年 Charles.Yao All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileWatcher.h"
#import "XYPlayer.h"

@interface VideoModel : NSObject <VLCMediaThumbnailerDelegate>

@property (nonatomic, assign) BOOL select;

@property (nonatomic, copy) NSString *videoName;

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, assign) int playTime;

@property (nonatomic, strong) NSString *videoImgPath;//[self saveImg:image withVideoMid:[NSString stringWithFormat:@"%lld", model.videoSize]

@property (nonatomic, assign) long long videoSize; // , @"videoSize":[SandBoxHelper fileSizeForPath:videoPath]

+ (NSMutableArray<VideoModel *> *)modelArrayWithDicArray:(NSArray<NSDictionary *> *)dataArray;

- (NSDictionary *)dictionaryFromModel;

@end
