//
//  NSColor+Category.h
//  MagicBoard_Mac
//
//  Created by wave on 16/11/1.
//  Copyright © 2016年 wave. All rights reserved.
//

#import <Cocoa/Cocoa.h>

///随机色
#define MMRandomColor [NSColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1]

///16进制颜色
#define MMRGBCOLOR(color) [NSColor colorWithRed:(((color)>>16)&0xff)*1.0/255.0 green:(((color)>>8)&0xff)*1.0/255.0 blue:((color)&0xff)*1.0/255.0 alpha:1.0].CGColor

@interface NSColor (Category)

+ (instancetype)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (instancetype)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

/// 灰
+(NSColor *)greyColor;

/// 深灰
+(NSColor *)deepGreyColor;

/// 浅灰
+(NSColor *)lightGreyColor;

/// 浅深灰
+(NSColor *)lightDeepGreyColor;

/// 导航栏灰
+(NSColor *)NavigationBarGeryColor;

/// 蓝色
+(NSColor *)blueColor;

/// 深蓝
+(NSColor *)deepBlueColor;

/// 背景色
+(NSColor *)backgroundColor;

@end
