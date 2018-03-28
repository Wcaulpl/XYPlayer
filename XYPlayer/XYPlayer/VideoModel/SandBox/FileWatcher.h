//
//  FileWatcher.h
//  GetLocalVideo
//
//  Created by Charles.Yao on 2016/11/11.
//  Copyright © 2016年 Charles.Yao All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SandBoxHelper.h"
#import <YYKit/YYKit.h>

@interface FileWatcher : NSObject

@property (nonatomic, strong) YYThreadSafeArray *dataSource;

+ (FileWatcher *)shared;
- (void)startManager;
- (void)stopManager;

- (void)deleteiTunesVideo:(NSArray *)array;

@end
