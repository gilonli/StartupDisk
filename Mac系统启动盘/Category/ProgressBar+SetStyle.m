//
//  ProgressBar+SetStyle.m
//  Mac系统启动盘
//
//  Created by dasen on 2017/1/24.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "ProgressBar+SetStyle.h"

@implementation ProgressBar (SetStyle)
- (void)setStyle{

    self.background  = UIColorRGB(0xECECEC);
    self.borderColor = [NSColor blackColor];
    self.foreground  = [NSColor blueColor];
    self.progress = 0;
    self.animated = YES;
    
}
- (void)setProgress:(CGFloat)progress{
    [super setProgress:progress];
    self.hidden = progress<=0.01? YES:NO;
}
@end
