//
//  DSAlert.m
//  Mac系统启动盘
//
//  Created by zhangdasen on 2017/1/16.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "DSAlert.h"
#import <CoreAudioKit/CoreAudioKit.h>
@implementation DSAlert

+ (void)alertWithString:(NSString *)string name:(NSString *)name{

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提示"];
    [alert setInformativeText:string];
    [alert addButtonWithTitle:@"确定"];
    if (!name.length) {
        name = @"icon00";
    }
    alert.icon = [NSImage imageNamed:name];
    
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
}

+ (void)alertWithTitle:(NSString *)firstname SecondTitle:(NSString *)secondname complate:(void(^)(BOOL state))complate{
    
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提示"];
    [alert setInformativeText:@"继续操作将先进行格式化磁盘，是否继续？"];
    [alert addButtonWithTitle:firstname];
    [alert addButtonWithTitle:secondname];
    alert.icon = [NSImage imageNamed:@"icon0"];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
      
    //响应window的按钮事件
    if(returnCode == NSAlertFirstButtonReturn)
    {
        complate(NO);
    }
    else if(returnCode == NSAlertSecondButtonReturn )
    {
        complate(YES);
    }

    }];
    
}

@end
