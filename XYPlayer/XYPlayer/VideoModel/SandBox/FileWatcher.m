//
//  FileWatcher.m
//  GetLocalVideo
//
//  Created by Charles.Yao on 2016/11/11.
//  Copyright © 2016年 Charles.Yao All rights reserved.
//

#import "FileWatcher.h"

dispatch_queue_t fileWatcher_queue() {
    static dispatch_queue_t as_fileWatcher_queue;
    static dispatch_once_t onceToken_fileWatcher;
    dispatch_once(&onceToken_fileWatcher, ^{
        as_fileWatcher_queue = dispatch_queue_create("fileWatcher.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return as_fileWatcher_queue;
}

@interface FileWatcher ()

@property (nonatomic, strong)  dispatch_source_t source;

@property (nonatomic, strong) YYThreadSafeArray *videoNameArr;

@property (nonatomic, assign) BOOL isConvenientFinished; //便利完成

@property (nonatomic, assign) BOOL isFinishedCopy; //复制完成标识

@end

@implementation FileWatcher

+ (FileWatcher *)shared {
    static FileWatcher *fileWatcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileWatcher = [[FileWatcher alloc] init];
    });
    return fileWatcher;
}

- (void)startManager {
    
    self.dataSource = [[YYThreadSafeArray alloc] init];
    self.videoNameArr = [[YYThreadSafeArray alloc] init];
    
    self.isFinishedCopy = YES;  //此标识是监听
    
    self.isConvenientFinished = YES;
    
    [self getiTunesVideo];
    
    [self startMonitorFile];
    
}

- (void)stopManager {
    
    dispatch_cancel(self.source);
}

- (void)startMonitorFile {  //监听Document文件夹的变化
    NSURL *directoryURL = [NSURL URLWithString:[SandBoxHelper docPath]]; //添加需要监听的目录
    int const fd =
    open([[directoryURL path] fileSystemRepresentation], O_EVTONLY);
    if (fd < 0) {
        
        NSLog(@"Unable to open the path = %@", [directoryURL path]);
        return;
    }
    dispatch_queue_t queue = YYDispatchQueueGetForQOS(NSQualityOfServiceUtility);

    dispatch_source_t source =
    dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd,
                           DISPATCH_VNODE_WRITE,
                           queue);
    
    dispatch_source_set_event_handler(source, ^() {
        unsigned long const type = dispatch_source_get_data(source);
        switch (type) {
            case DISPATCH_VNODE_WRITE: {
                NSLog(@"Document目录内容发生变化!!!");
                if (self.isConvenientFinished) {
                    self.isConvenientFinished = NO;
                    [self directoryDidChange];
                }
                break;
            }
            default:
                break;
        }
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
    });
    
    self.source = source;
    dispatch_resume(self.source);
}

#pragma mark 检索是不是通过iTunes导入视频引起的调用
- (void)directoryDidChange {
    [self getiTunesVideo];
}

- (void)getiTunesVideo {
    
    dispatch_async(fileWatcher_queue(), ^{
        //获取沙盒里所有文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //在这里获取应用程序Documents文件夹里的文件及文件夹列表
        NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;// [documentPaths objectAtIndex:0];
        NSError *error = nil;
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
        if (fileList.count > 0) {
            for (NSString *file in fileList) {
                
                NSString * videoPath = [documentDir stringByAppendingPathComponent:file];
                NSString *string = @".rmvb//.asf//.avi//.divx//.dv//.flv//.gxf//.m1v//.m2v//.m2ts//.m4v//.mkv//.mov//.mp2//.mp4//.mpeg//.mpeg1//.mpeg2//.mpeg4//.mpg//.mts//.mxf//.ogg//.ogm//.ps//.ts//.vob//.wmv//.a52//.aac//.ac3//.dts//.flac//.m4a//.m4p//.mka//.mod//.mp1//.mp2//.mp3//.ogg";
                NSArray * arr = [string componentsSeparatedByString:@"//"];
                __weak typeof(self) weakSelf = self;
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([videoPath containsString:obj] || [videoPath containsString: [(NSString *)obj uppercaseString]]) {
                        NSArray *lyricArr = [videoPath componentsSeparatedByString:@"/"];
                        //此判断的作用：避免同一资源的反复添加，使资源只添加过一次后，只要不删，就不会再重新获取路径、图片等
                        if (![self.videoNameArr containsObject:[lyricArr lastObject]]) {
                            [self.videoNameArr addObject:[lyricArr lastObject]];
                            NSInteger lastSize = 0;
                            NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil];
                            NSInteger fileSize = [[fileAttrs objectForKey:NSFileSize] intValue];
                            do {
                                lastSize = fileSize;
                                weakSelf.isFinishedCopy = NO;
                                fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil];
                                fileSize = [[fileAttrs objectForKey:NSFileSize] intValue];
                            } while (lastSize != fileSize);
                            weakSelf.isFinishedCopy = YES;
//                            YYThreadSafeDictionary *dic = [YYThreadSafeDictionary dictionaryWithDictionary:@{@"videoName":[videoPath componentsSeparatedByString:@"/"].lastObject, @"videoPath":videoPath}];
                            [weakSelf.dataSource addObject:videoPath];
                            [weakSelf directoryDidChange];
                        }
                        *stop = YES;
                        
                        if (*stop) {
                            // 刷新界面
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.refreshiTunesUI.notification" object:nil];
                        }
                    }
                    
                }];
                
            }
        }
        
        self.isConvenientFinished = YES;
    });
}

- (void)deleteiTunesVideo:(NSArray *)array {
    for (NSDictionary *item in array) {
        [self.dataSource removeObject:item];
        [SandBoxHelper deleteFile:item[@"videoPath"]];
        [SandBoxHelper deleteFile:item[@"videoImgPath"]];
        [self.videoNameArr removeObject:item[@"videoName"]];
    }
}

@end
