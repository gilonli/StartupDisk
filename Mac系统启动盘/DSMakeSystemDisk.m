//
//  DSMakeSystemDisk.m
//  Mac系统启动盘
//
//  Created by zhangdasen on 2017/1/16.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "DSMakeSystemDisk.h"
#import "FileDragView.h"
#import "DADSDiskTool.h"

@interface DSMakeSystemDisk ()

@property (nonatomic,weak)DADSDiskTool *diskTool;

@end

@implementation DSMakeSystemDisk

- (instancetype)initWithDiskTool:(DADSDiskTool *)diskTool
{
    if (self = [super init]) {
        _diskTool = diskTool;
    }
    return self;
}

/// 组合命令，和进行调用命令方法
- (void)makeStartupDiskWithSystemPath:(NSString *)systemPath disk:(NSString *)diskInfo
{
    // 检查路径
    if (![self checkPathWithPath:systemPath diskInfo:diskInfo]) {
        return;
    }
   
    // 组合命令
    NSMutableArray *codeArray = [NSMutableArray array];
    DADiskRef disk = [self.diskTool getDiskWithDiskInfo:diskInfo];
    [codeArray addObject:[self makeCodeWithPath:systemPath disk:disk]];
    
    // 执行命令
    [DSAlert alertWithTitle:@"取消" SecondTitle:@"确定" complate:^(BOOL state) {
        if (state) {
            [self startWithParameter:codeArray disk:disk progress:^(NSString *log) {
                [self.delegate makeSystemDiskEnd:log];
            }];
        }
    }];
}

#pragma mark - 事件方法

/// 字符串空格转换，为了防止空格不识别
- (NSString *)charactersInSetWithString:(NSString *)str{
    return [[str componentsSeparatedByCharactersInSet:FileDoNotWant(@" ")]componentsJoinedByString:replaceChar];
}

/// 拼接制作系统盘的命令
- (NSString *)makeCodeWithPath:(NSString *)systemPath disk:(DADiskRef)disk{
    
    // 拼接命令
    NSString *diskPath    = [NSString stringWithFormat:@"/Volumes/%@",VolumeName];
    systemPath = [self charactersInSetWithString:systemPath];
    diskPath   = [self charactersInSetWithString:diskPath];
    
    NSString *toolPath   = [NSString stringWithFormat:@"%@/Contents/Resources/createinstallmedia",systemPath];
    NSString *makeSetup  = [NSString stringWithFormat:@"%@ --volume %@ --applicationpath %@ --nointeraction",toolPath,diskPath,systemPath];

    return makeSetup;
}

/// 校验路径和磁盘是否有问题
- (BOOL)checkPathWithPath:(NSString *)systemPath diskInfo:(NSString *)info{

    if (!systemPath.length || ![FileDragView checkSystemPath:systemPath]) {
        [DSAlert alertWithString:@"系统安装包路径有误，请确认正确的系统安装包路径！" name:@"icon03"];
        [self.delegate makeSystemDiskPathError];
        return NO;
    }
    
    if ([info componentsSeparatedByString:@" "].count == 1) {
        [DSAlert alertWithString:@"未选择磁盘，请先选择盘符。" name:@"icon00"];
        return NO;
    }
    
    if (![self.diskTool isDiskLoadedWithName:info]) {
        [DSAlert alertWithString:@"磁盘未装载，请先装载磁盘，或重新插入磁盘" name:@"iconusb"];
        return NO;
    }
    return YES;
}

@end
