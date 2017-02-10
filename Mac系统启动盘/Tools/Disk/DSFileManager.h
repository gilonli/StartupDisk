//
//  DSFileManager.h
//  Mac系统启动盘
//
//  Created by dasen on 2017/1/24.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSFileManager : NSObject

+ (float)folderSizeAtPath:(NSString*) folderPath;
+ (void)renameFileWithPath:(NSString *)path;
@end
