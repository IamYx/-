//
//  YXOne.m
//  YXSDK
//
//  Created by 姚肖 on 2023/5/18.
//

#import "YXFileManager.h"
#import <AVFoundation/AVFoundation.h>

@interface YXFileManager()<NSURLSessionDownloadDelegate>

@property (nonatomic, copy)YXUploadProgressBlock progressBlock;
@property (nonatomic, copy)YXUploadSuccessBlock successBlock;
@property (nonatomic, copy)YXUploadFailureBlock failureBlock;
@property (nonatomic, strong)NSString *downLoadGroup;
@property (nonatomic, strong)NSURLSessionConfiguration *configuration;
@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSMutableArray *dlTasks;

@end

@implementation YXFileManager

+ (instancetype)sharedManager {
    static YXFileManager *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[YXFileManager alloc] init];
    });
    return _sharedSingleton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dlTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (BOOL)saveValue:(NSDictionary *)accid key:(NSString *)token {
    if (![accid isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
    [userDefalts setObject:accid forKey:token];
    return YES;
}

+ (NSDictionary *)getValueForKey:(NSString *)token {
    NSUserDefaults *userDefalts = [NSUserDefaults standardUserDefaults];
    if ([[userDefalts objectForKey:token] isKindOfClass:[NSDictionary class]]) {
        return [userDefalts objectForKey:token];
    }
    return @{};
}

+ (NSString *)musicFileFromPath:(NSString *)name {
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [YXFileManager filePath:@"music"], name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        return filePath;
    } else {
        return nil;
    }
}

+ (BOOL)changeFileNameWithPath:(NSString *)path oldName:(NSString *)oldName newName:(NSString *)newName {
    path = [path stringByAppendingString:@"/"];
    NSString *oldFilePath = [path stringByAppendingString:oldName];
    NSString *newFilePath = [path stringByAppendingString:newName];
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];

    if (success) {
        NSLog(@"文件名修改成功");
        return YES;
    } else {
        NSLog(@"文件名修改失败：%@", error.localizedDescription);
        return NO;
    }
}

+ (NSString *)saveFileToGroup:(NSString *)groupName data:(NSData *)data {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // 判断文件夹是否存在
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:groupName];
    BOOL isDir = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!isExist || !isDir) {
        // 文件夹不存在，创建一个文件夹
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!success) {
            return @"创建文件夹失败";
        }
    }
    
    // 定义要写入的文件路径和文件名
    NSString *timeStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    timeStr = [timeStr stringByAppendingString:@"_image.jpg"];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDirectory, groupName, timeStr];
    
    // 将NSData对象写入文件
    if (![data writeToFile:filePath atomically:YES]) {
        return @"Error saving file";
    }
    
    return filePath;
}


+ (NSArray *)outPutFileFromGroup:(NSString *)groupName {
    // 获取Documents目录的路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingFormat:@"/%@", groupName];
    
    // 获取目录下的所有文件和文件夹
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error) {
        NSLog(@"Error reading directory: %@", error.localizedDescription);
    } else {
        
    }
    //排序
    NSArray *newFiles = [files sortedArrayUsingComparator:^NSComparisonResult(NSString *timeStamp1, NSString *timeStamp2) {
        
        if ([timeStamp1 componentsSeparatedByString:@"_"].count > 1) {
            timeStamp1 = [timeStamp1 componentsSeparatedByString:@"_"].firstObject;
        } else {
            timeStamp1 = @"0";
        }
        
        if ([timeStamp2 componentsSeparatedByString:@"_"].count > 1) {
            timeStamp2 = [timeStamp2 componentsSeparatedByString:@"_"].firstObject;
        } else {
            timeStamp2 = @"0";
        }
        
        NSTimeInterval timeInterval1 = [timeStamp1 doubleValue];
        NSTimeInterval timeInterval2 = [timeStamp2 doubleValue];

        if (timeInterval1 < timeInterval2) {
            return NSOrderedDescending;
        } else if (timeInterval1 > timeInterval2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    return newFiles;
}

+ (NSString *)filePath:(NSString *)groupName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // 判断文件夹是否存在
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:groupName];
    BOOL isDir = NO;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    if (!isExist || !isDir) {
        // 文件夹不存在，创建一个文件夹
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (!success) {
            NSLog(@"创建文件夹失败");
        }
    }
    
    documentsDirectory = [documentsDirectory stringByAppendingFormat:@"/%@", groupName];
    return documentsDirectory;
}

+ (BOOL)deleteGroup:(NSString *)groupName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [documentsDirectory stringByAppendingFormat:@"/%@", groupName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success = [fileManager removeItemAtPath:folderPath error:&error];
    return success;
}

+ (BOOL)deleteFileWithPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error;
        if ([fileManager removeItemAtPath:path error:&error]) {
            NSLog(@"文件删除成功");
            return YES;
        } else {
            NSLog(@"文件删除失败：%@", error);
            return NO;
        }
    } else {
        NSLog(@"文件不存在");
        return NO;
    }
}

- (NSURLSessionDownloadTask *)downLoadFile:(NSString *)URLString groupName:(NSString *)groupName
            progress:(YXUploadProgressBlock)uploadProgress
         success:(YXUploadSuccessBlock)success
         failure:(YXUploadFailureBlock)failure {
    
    if (_dlTasks.count > 6) {
        NSLog(@"下载任务不能超过6个");
        return nil;
    }
    
    NSString *fileURLString = URLString;
    NSURL *fileURL = [NSURL URLWithString:fileURLString];
    
    _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //支持后台下载（进入后台之后进度不会打印，但是还在下载）
    _configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.yxsdk.backgroudSession"];
    _session = [NSURLSession sessionWithConfiguration:_configuration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithRequest:[NSURLRequest requestWithURL:fileURL]];
    
    _progressBlock = uploadProgress;
    _successBlock = success;
    _failureBlock = failure;
    _downLoadGroup = groupName;
    [_dlTasks addObject:downloadTask];
    [downloadTask resume];
    return downloadTask;
}

- (void)cancelDownLoad {
    for (NSURLSessionDownloadTask *task in _dlTasks) {
        [task cancel];
    }
    [_dlTasks removeAllObjects];
    _session = Nil;
}

//b c b a b b a b d d b e d a a c b d c e


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [NSURL URLWithString:[YXFileManager filePath:_downLoadGroup]];
    NSString *name = [NSString stringWithFormat:@"%f_%@", [[NSDate date] timeIntervalSince1970], downloadTask.response.suggestedFilename];
    NSURL *destinationURL = [documentsURL URLByAppendingPathComponent:name];
    destinationURL = [NSURL fileURLWithPath:destinationURL.path];
//    NSLog(@" %@ ", destinationURL);
    NSError *error = nil;
    BOOL success = [fileManager moveItemAtURL:location toURL:destinationURL error:&error];
    if (success) {
        NSLog(@"下载成功，文件保存在：%@", destinationURL);
        _successBlock(destinationURL.path);
    } else {
        NSLog(@"下载失败，错误信息：%@", error.localizedDescription);
        _failureBlock(error);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (downloadTask.state == NSURLSessionTaskStateRunning && _session) {
        // 进度计算
        CGFloat progress = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;
        NSInteger index = -1;
        if ([_dlTasks containsObject:downloadTask]) {
            index = [_dlTasks indexOfObject:downloadTask];
            NSLog(@"%ld任务下载进度：%f, 总大小 %lldMB", index, progress, totalBytesExpectedToWrite/1024/1024);
            _progressBlock(progress, index);
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"下载失败，错误信息：%@", error.localizedDescription);
        _failureBlock(error);
    }
    [_dlTasks removeObject:task];
}

+ (NSInteger)audioFileTime:(NSString *)filepath {
    NSInteger mediaLength = 0;
    if( [[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSURL    *movieURL = [NSURL fileURLWithPath:filepath];
        AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:movieURL options:nil];
        CMTime time = urlAsset.duration;
        mediaLength = CMTimeGetSeconds(time) * 1000;
    }
    return mediaLength;
}

@end
