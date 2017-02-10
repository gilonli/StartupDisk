//
//  DSFileManager.m
//  Mac系统启动盘
//
//  Created by dasen on 2017/1/24.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "DSFileManager.h"

@implementation DSFileManager
+ (float)folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize/(1024.0*1024.0);
    
}
+ (long long)fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (void)renameFileWithPath:(NSString *)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray *muArray =[path componentsSeparatedByString:@"/"].mutableCopy;
    [muArray removeLastObject];
    [muArray addObject:@"system.app"];
    NSString *newPath = [muArray componentsJoinedByString:@"/"];
    [manager moveItemAtPath:path  toPath:newPath error:nil];
}
@end
