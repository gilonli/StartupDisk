//
//  NSColor+Category.m
//  MagicBoard_Mac
//
//  Created by wave on 16/11/1.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "NSColor+Category.h"

@implementation NSColor (Category)


/// 灰
+(NSColor *)greyColor{
    return [self colorWithHexString:@"B1B1B1" alpha:1.0];
}

/// 深灰
+(NSColor *)deepGreyColor{
    return [self colorWithHexString:@"888888" alpha:1.0];
}

/// 浅灰
+(NSColor *)lightGreyColor{
    return [self colorWithHexString:@"E3E3E3" alpha:1.0];
}

/// 浅深灰
+(NSColor *)lightDeepGreyColor{
    return [self colorWithHexString:@"C9C9C9" alpha:1.0];
}

/// 导航栏灰
+(NSColor *)NavigationBarGeryColor{
    return [self colorWithHexString:@"D8D8D8" alpha:1.0];
}

/// 蓝色
+(NSColor *)blueColor{
    return [self colorWithHexString:@"388EEE" alpha:1.0];
}

/// 深蓝
+(NSColor *)deepBlueColor{
    return [self colorWithHexString:@"2465A2" alpha:1.0];
}

+(NSColor *)backgroundColor{
    return [self colorWithHexString:@"ECECEC" alpha:1.0];
}






+ (NSColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [NSColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [NSColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [NSColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (NSColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}

@end

