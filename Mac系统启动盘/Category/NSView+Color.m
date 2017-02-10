//
//  NSView+Color.m
//  MagicBoard_Mac
//
//  Created by wave on 16/11/3.
//  Copyright © 2016年 wave. All rights reserved.
//

#import "NSView+Color.h"
#import <objc/runtime.h>
#import "NSColor+Category.h"
static const void *backgroundColorKey = &backgroundColorKey;

@implementation NSView (Color)

-(void)setMm_backgroundColor:(NSString *)mm_backgroundColor{
    self.wantsLayer = YES;
    objc_setAssociatedObject(self, backgroundColorKey, mm_backgroundColor, OBJC_ASSOCIATION_COPY);
    self.layer.backgroundColor = [NSColor colorWithHexString:mm_backgroundColor].CGColor;
}

-(NSString *)mm_backgroundColor{
    return objc_getAssociatedObject(self, backgroundColorKey);
}

-(void)setMm_BackgroundColor:(NSColor *)mm_BackgroundColor{
    self.wantsLayer = YES;
    self.layer.backgroundColor = mm_BackgroundColor.CGColor;
    objc_setAssociatedObject(self, [NSStringFromSelector(@selector(setMm_BackgroundColor:)) cStringUsingEncoding:NSUTF8StringEncoding], mm_BackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSColor *)mm_BackgroundColor{
    return objc_getAssociatedObject(self, [NSStringFromSelector(@selector(setMm_BackgroundColor:)) cStringUsingEncoding:NSUTF8StringEncoding]);
}


@end
