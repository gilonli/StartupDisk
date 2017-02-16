//
//  DSAlert.h
//  Mac系统启动盘
//
//  Created by zhangdasen on 2017/1/16.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudioKit/CoreAudioKit.h>
@interface DSAlert : NSObject
+ (void)alertWithString:(NSString *)string name:(NSString *)name;
+ (void)alertWithTitle:(NSString *)firstname SecondTitle:(NSString *)secondname complate:(void(^)(BOOL state))complate;
@end
