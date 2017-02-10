//
//  DSTask.h
//  Mac系统启动盘
//
//  Created by Dasen on 2017/1/14.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^progressBlock)(NSString *log);


@protocol DSTaskdelegate <NSObject>
- (void)makeSystemDiskStateNormal;
- (void)makeSystemDiskPathError;
- (void)makeSystemDiskEnd:(NSString *)log;
- (void)makeSystemDiskProcess:(CGFloat)process;
@end


@interface DSTask : NSObject

@property (nonatomic, weak)id<DSTaskdelegate> delegate;

- (void)startWithParameter:(NSMutableArray *)parameter disk:(DADiskRef)disk progress:(progressBlock)progress;

@end
