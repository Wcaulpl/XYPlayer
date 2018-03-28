//
//  VideoModel.m
//  GetLocalVideo
//
//  Created by Charles.Yao on 2016/11/11.
//  Copyright © 2016年 Charles.Yao All rights reserved.
//

#import "VideoModel.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface VideoModel ()

@end

@implementation VideoModel

+ (NSMutableArray<VideoModel *> *)modelArrayWithDicArray:(NSArray<NSDictionary *> *)dataArray {
    YYThreadSafeArray *array = [YYThreadSafeArray array];
    YYThreadSafeArray *mediaArray = [YYThreadSafeArray array];
    for (NSString *videoPath in dataArray) {
        VideoModel *model = [[self alloc] init];
        model.videoName = [videoPath componentsSeparatedByString:@"/"].lastObject;
        model.videoPath = videoPath;
        model.videoSize = [SandBoxHelper fileSizeForPath:model.videoPath];
        if ([model.videoName containsString:@"media"]) {
            [mediaArray addObject:model];
        } else {
            [array addObject:model];
        }
        //初始化并设置代理
        VLCMediaThumbnailer *thumbnailer = [VLCMediaThumbnailer thumbnailerWithMedia:[[VLCMedia alloc]  initWithPath:model.videoPath] andDelegate:model];
        //开始获取缩略图
        [thumbnailer fetchThumbnail];
        
    }
    [XYVLCPlayer sharedPlayer].mediaArray = mediaArray;
    return array;
}

- (NSDictionary *)dictionaryFromModel
{
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        id value = [self valueForKey:key];
        
        //only add it to dictionary if it is not nil
        if (key && value) {
            if ([value isKindOfClass:[NSString class]]
                || [value isKindOfClass:[NSNumber class]]) {
                // 普通类型的直接变成字典的值
                [dict setObject:value forKey:key];
            }
            else if ([value isKindOfClass:[NSArray class]]
                     || [value isKindOfClass:[NSDictionary class]]) {
                // 数组类型或字典类型
                [dict setObject:[self idFromObject:value] forKey:key];
            }
            else {
                // 如果model里有其他自定义模型，则递归将其转换为字典
                [dict setObject:[value dictionaryFromModel] forKey:key];
            }
        } else if (key && value == nil) {
            // 如果当前对象该值为空，设为nil。在字典中直接加nil会抛异常，需要加NSNull对象
            [dict setObject:[NSNull null] forKey:key];
        }
    }
    
    free(properties);
    return dict;
}

- (id)idFromObject:(nonnull id)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        if (object != nil && [object count] > 0) {
            NSMutableArray *array = [NSMutableArray array];
            for (id obj in object) {
                // 基本类型直接添加
                if ([obj isKindOfClass:[NSString class]]
                    || [obj isKindOfClass:[NSNumber class]]) {
                    [array addObject:obj];
                }
                // 字典或数组需递归处理
                else if ([obj isKindOfClass:[NSDictionary class]]
                         || [obj isKindOfClass:[NSArray class]]) {
                    [array addObject:[self idFromObject:obj]];
                }
                // model转化为字典
                else {
                    [array addObject:[obj dictionaryFromModel]];
                }
            }
            return array;
        }
        else {
            return object ? : [NSNull null];
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        if (object && [[object allKeys] count] > 0) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (NSString *key in [object allKeys]) {
                // 基本类型直接添加
                if ([object[key] isKindOfClass:[NSNumber class]]
                    || [object[key] isKindOfClass:[NSString class]]) {
                    [dic setObject:object[key] forKey:key];
                }
                // 字典或数组需递归处理
                else if ([object[key] isKindOfClass:[NSArray class]]
                         || [object[key] isKindOfClass:[NSDictionary class]]) {
                    [dic setObject:[self idFromObject:object[key]] forKey:key];
                }
                // model转化为字典
                else {
                    [dic setObject:[object[key] dictionaryFromModel] forKey:key];
                }
            }
            return dic;
        }
        else {
            return object ? : [NSNull null];
        }
    }
    
    return [NSNull null];
}

//获取缩略图超时
- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer{
    NSLog(@"getThumbnailer time out.");
    [self saveImg:nil withVideoMid:[NSString stringWithFormat:@"%lld", self.videoSize]];
}
//获取缩略图成功
- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail{
    //获取缩略图
    UIImage *image = [UIImage imageWithCGImage:thumbnail];
    [self saveImg:image withVideoMid:[NSString stringWithFormat:@"%lld", self.videoSize]];
}

- (void)saveImg:(UIImage *)image withVideoMid:(NSString *)videoMid{
    
    if (!image) {
        image = [UIImage imageNamed:@"posters_default_horizontal"];
    }
    if (!videoMid) {
        videoMid = [self uuid];
    }
    //png格式
    NSData *imagedata=UIImagePNGRepresentation(image);
    
    NSString *savedImagePath = [[SandBoxHelper iTunesVideoImagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", videoMid]];
    
    [imagedata writeToFile:savedImagePath atomically:YES];
    self.videoImgPath = savedImagePath;
}

- (NSString *)uuid {
    // create a new UUID which you own
    CFUUIDRef uuidref = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    CFStringRef uuid = CFUUIDCreateString(kCFAllocatorDefault, uuidref);
    
    NSString *result = (__bridge NSString *)uuid;
    //release the uuidref
    CFRelease(uuidref);
    // release the UUID
    CFRelease(uuid);
    
    return result;
}

@end
