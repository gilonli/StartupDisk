//
//  DSTask.m
//  Mac系统启动盘
//
//  Created by Dasen on 2017/1/14.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "DSTask.h"
#import "STPrivilegedTask.h"
#import "DSFileManager.h"

#define DSNotification [NSNotificationCenter defaultCenter]

#define DiskDisappeared @"DiskDisappeared"

@interface DSTask ()

@property (nonatomic, copy)NSString *bsdName;
@property (nonatomic, copy)progressBlock progress;
@property (nonatomic, strong)STPrivilegedTask *task;
@property (nonatomic, strong)NSMutableArray *codeArray;
@property (nonatomic, strong)NSTimer *sizeTimer;

@end

@implementation DSTask
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(diskDisappeared:) name:DiskDisappeared object:nil];
    }
    return self;
}

- (void)startWithParameter:(NSMutableArray *)parameter disk:(DADiskRef)disk progress:(progressBlock)progress
{
    _progress          = progress;
    self.codeArray     = parameter;
    self.bsdName       = BSDName;
    [self runShell];
}

- (void)diskDisappeared:(NSNotification *)objc {
    DADiskRef disk = (__bridge DADiskRef)(objc.object);
    NSString *bsdName = BSDName;
    NSString *bsd = [self.bsdName substringToIndex:5];
    if ([bsdName isEqualToString:bsd]) {
        self.bsdName = nil;
        [self.sizeTimer invalidate];
        [DSAlert alertWithString:@"磁盘非正常退出，请重新插入U盘，并重新点击一键制作！" name:nil];
        [self.delegate makeSystemDiskStateNormal];
    }else{
        NSLog(@"硬盘没有被退出");
    }
}

- (void)startClock{
    NSString *filePath = self.codeArray[4];
    NSString *volumeFilePath = @"/Volumes/Install macOS Sierra" ;
    __weak typeof(self)wself = self;
    
    // 监听进度
    self.sizeTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        CGFloat fileSize   = [DSFileManager folderSizeAtPath:filePath];
        CGFloat toFileSzie = [DSFileManager folderSizeAtPath:volumeFilePath];
        CGFloat process    = toFileSzie / fileSize;
        [self.delegate makeSystemDiskProcess:process];
        if (fileSize < toFileSzie) {
            [wself.sizeTimer invalidate];
             wself.progress(@"制作完成");
        }
    }];
}

- (void)resetTask{
    self.task = [[STPrivilegedTask alloc]init];
}

- (void)runShell{
    
    if (!self.codeArray.count) { return; }
    
    [self resetTask];
    
    // 配置运行参数
    NSString *code = self.codeArray[0];
    NSMutableArray *parameter = [code componentsSeparatedByString:@" "].mutableCopy;
    for (int i =0; i<parameter.count; i++) {
        NSString *tempStr = parameter[i];
        tempStr = [[tempStr componentsSeparatedByCharactersInSet:FileDoNotWant(replaceChar)]componentsJoinedByString:@" "];
        parameter[i] = tempStr;
    }
    
    [self.task setLaunchPath:parameter.firstObject];
    [self.task setArguments:parameter];
    self.codeArray = parameter;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.task launch];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startClock];
        });
        [self.task waitUntilExit];
    });
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - 懒加载
- (NSMutableArray *)codeArray
{
    if (!_codeArray) {
        _codeArray = [NSMutableArray array];
    }
    return _codeArray;
}
@end
