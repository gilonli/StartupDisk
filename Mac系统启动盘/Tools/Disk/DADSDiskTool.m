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
    
    //运行循环的调度会话。
    DASessionScheduleWithRunLoop(session,CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    DARegisterDiskDescriptionChangedCallback(session, NULL, NULL, DiskDescription, NULL);

    //注销一个核心基础对象。
    CFRelease(session);
}
void DiskDescription( DADiskRef disk,CFArrayRef keys,void *context){
    [selfObjc.comBoxdelegate diskDidChangeState:selfObjc.diskDict];
}

void hello_disk(DADiskRef disk, void *context){
    [selfObjc diskChange:DiskChangeTypeAppear disk:disk];
}

void goodbye_disk(DADiskRef disk, void *context){
    [selfObjc diskChange:DiskChangeTypeDismiss disk:disk];
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

- (void)diskChange:(DiskChangeType)state disk:(DADiskRef)disk{
    if (![VolumeName length] || ![BSDName length] || ![self checkDiskType:disk]) {
        return;
    }
    
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

+ (NSString *)getApendDiskNameWithDisk:(DADiskRef)disk{
    
    NSString *mediaSize = [NSString stringWithFormat:@"%.2fG",DiskSize];
    return [NSString stringWithFormat:@"%@ - - %@ (%@)",BSDName,VolumeName,mediaSize];
}

- (BOOL)checkDiskType:(DADiskRef)disk{
    if (![DiskProtocol isEqualToString:@"USB"] || !VolumeName || DiskSize < 8.0) {
        return NO;
    }
    return YES;
}

- (DADiskRef)getDiskWithDiskInfo:(NSString *)name{
    NSString *bsdName = [name componentsSeparatedByString:@" "].firstObject;
    return (__bridge DADiskRef)([self.diskDict valueForKey:bsdName]);
}

- (BOOL)isDiskLoadedWithName:(NSString *)name
{
    NSString *bsdName = [name componentsSeparatedByString:@" "].firstObject;
    DADiskRef disk    = (__bridge DADiskRef)([self.diskDict valueForKey:bsdName]);
    if (![[VolumePath absoluteString] length]) {
        return NO;
    }
    return YES;
}

+ (void)diskRenameWithdisk:(DADiskRef)disk;
{
    CFStringRef strRef = (__bridge CFStringRef)BSDName;
    DADiskRename(disk, strRef, kDADiskRenameOptionDefault, NULL, NULL);
}

- (NSMutableDictionary *)diskDict
{
    if (!_diskDict) {
        _diskDict = [NSMutableDictionary dictionary];
    }
    return _diskDict;
}
@end
