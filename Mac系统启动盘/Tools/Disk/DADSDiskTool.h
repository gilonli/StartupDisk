//
//  DSDaDiskTool.h
//  Mac系统启动盘
//
//  Created by dasen on 2017/1/23.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DADSDiskTool.h"
typedef NS_OPTIONS (NSInteger,DiskChangeType){
    DiskChangeTypeAppear,
    DiskChangeTypeDismiss
};

@protocol DADSDiskToolDelegate <NSObject>

- (void)diskDidChangeState:(NSMutableDictionary *)diskDict;

@end

@interface DADSDiskTool : NSObject

@property (nonatomic, weak)id<DADSDiskToolDelegate> comBoxdelegate;

+ (void)registerDiskNotice;
- (BOOL)isDiskLoadedWithName:(NSString *)name;

+ (NSString *)getApendDiskNameWithDisk:(DADiskRef)disk;
- (DADiskRef)getDiskWithDiskInfo:(NSString *)name;

@end
