//
//  DSMakeSystemDisk.h
//  Mac系统启动盘
//
//  Created by zhangdasen on 2017/1/16.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSTask.h"
@class DADSDiskTool;

@interface DSMakeSystemDisk : DSTask

- (instancetype)initWithDiskTool:(DADSDiskTool *)diskTool;

- (void)makeStartupDiskWithSystemPath:(NSString *)systemPath disk:(NSString *)disk;

@end
