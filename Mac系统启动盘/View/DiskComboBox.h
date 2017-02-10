//
//  DiskComboBox.h
//  Mac系统启动盘
//
//  Created by Dasen on 2017/1/14.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DADSDiskTool;

@interface DiskComboBox : NSComboBox

@property (nonatomic,weak)DADSDiskTool *diskTool;

@end
