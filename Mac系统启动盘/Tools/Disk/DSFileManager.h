//
//  DSFileManager.h
//  Mac系统启动盘
//
//  Created by dasen on 2017/1/24.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSFileManager : NSObject
//// 获取文件大小
+ (float)folderSizeAtPath:(NSString*) folderPath;

/// 重命名
+ (void)renameFileWithPath:(NSString *)path;
@end
