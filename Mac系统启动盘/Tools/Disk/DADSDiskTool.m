//
//  DSDaDiskTool.m
//  Mac系统启动盘
//
//  Created by dasen on 2017/1/23.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <DiskArbitration/DiskArbitration.h>
#import "DADSDiskTool.h"

#define DiskDisappeared @"DiskDisappeared"

static DADSDiskTool *selfObjc = nil;

@interface DADSDiskTool ()

@property (nonatomic, strong)NSMutableDictionary *diskDict;

@end

@implementation DADSDiskTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        selfObjc = self;
        [DADSDiskTool registerDiskNotice];
    }
    return self;
}

+ (void)registerDiskNotice{
    
    //创建一个新的会话
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    
    //注册一个回调函数被称为磁盘时已经探测。
    DARegisterDiskMountApprovalCallback(session,NULL,hello_diskmount,NULL);
    
    //注册一个回调函数的调用，每当一个卷卸载。
    DARegisterDiskUnmountApprovalCallback(session, NULL, goodbye_diskmount, NULL);
    
    //注册一个回调函数称为每当一个磁盘已经出现了。
    DARegisterDiskAppearedCallback(session, NULL, hello_disk, NULL);
    
    //注册一个回调函数称为每当一个磁盘已经消失了。
    DARegisterDiskDisappearedCallback(session, NULL, goodbye_disk, NULL);
    
    //注册磁盘信息变化回调
    DARegisterDiskDescriptionChangedCallback(session, NULL, NULL, DiskDescription, NULL);
    
    //运行循环的调度会话。
    DASessionScheduleWithRunLoop(session,CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    //注销一个核心基础对象。
    CFRelease(session);
}

void DiskDescription( DADiskRef disk,CFArrayRef keys,void *context){
    // 磁盘休息修改后，通过代理，告诉comBox要刷新视图
    [selfObjc.comBoxdelegate diskDidChangeState:selfObjc.diskDict];
}

void hello_disk(DADiskRef disk, void *context){
    
    [selfObjc diskChange:DiskChangeTypeAppear disk:disk];
}

void goodbye_disk(DADiskRef disk, void *context){
    [selfObjc diskChange:DiskChangeTypeDismiss disk:disk];
    /// 磁盘拔出或异常中断后，发出通知，用于处理中断的通知。
    [[NSNotificationCenter defaultCenter]postNotificationName:DiskDisappeared object:(__bridge id _Nullable)(disk)];
}

DADissenterRef hello_diskmount(DADiskRef disk, void *context){
    [selfObjc diskChange:DiskChangeTypeAppear disk:disk];
    return NULL;
}

DADissenterRef goodbye_diskmount(DADiskRef disk, void *context){
    [selfObjc diskChange:DiskChangeTypeDismiss disk:disk];
    return NULL;
}

/// 统一处理磁盘的装载与卸载
- (void)diskChange:(DiskChangeType)state disk:(DADiskRef)disk{
    NSLog(@"%@",Disk_Des);
    // 过滤掉系统盘符，和小于8G的盘符
    if (![VolumeName length] || ![BSDName length] || ![self checkDiskType:disk]) {
        return;
    }
    // 用于记录磁盘，为了给combox传递数据
    switch (state) {
            case DiskChangeTypeAppear:
            [self.diskDict setValue:(__bridge id _Nullable)(disk) forKey:BSDName];
            break;
            case DiskChangeTypeDismiss:
            [self.diskDict removeObjectForKey:BSDName];
        default:
            break;
    }
    
    [self.comBoxdelegate diskDidChangeState:self.diskDict];
}

/// 拼接磁盘描述名称
+ (NSString *)getApendDiskNameWithDisk:(DADiskRef)disk{
    
    NSString *mediaSize = [NSString stringWithFormat:@"%.2fG",DiskSize];
    return [NSString stringWithFormat:@"%@ - - %@ (%@)",BSDName,VolumeName,mediaSize];
}

/// 检查是不是移动盘符
- (BOOL)checkDiskType:(DADiskRef)disk{
    if (![DiskProtocol isEqualToString:@"USB"] || !VolumeName || DiskSize < 8.0) {
        return NO;
    }
    return YES;
}

/// 根据磁盘描述信息，获取磁盘对象
- (DADiskRef)getDiskWithDiskInfo:(NSString *)name{
    NSString *bsdName = [name componentsSeparatedByString:@" "].firstObject;
    return (__bridge DADiskRef)([self.diskDict valueForKey:bsdName]);
}

/// 磁盘是否装载
- (BOOL)isDiskLoadedWithName:(NSString *)name
{
    NSString *bsdName = [name componentsSeparatedByString:@" "].firstObject;
    DADiskRef disk    = (__bridge DADiskRef)([self.diskDict valueForKey:bsdName]);
    if (![[VolumePath absoluteString] length]) {
        return NO;
    }
    return YES;
}

- (NSMutableDictionary *)diskDict
{
    if (!_diskDict) {
        _diskDict = [NSMutableDictionary dictionary];
    }
    return _diskDict;
}
@end
