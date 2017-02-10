//
//  FileDragView.h
//  DragDropDemo
//
//  Created by zhaojw on 15/10/21.
//  Copyright © 2015年 zhaojw. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FileDragViewDelegate <NSObject>

- (void)didFinishDragWithFile:(NSString *)filePath;

@end

@interface FileDragView : NSView
@property (nonatomic , weak)id<FileDragViewDelegate> delegate;
+ (BOOL)checkSystemPath:(NSString *)systemPath;
@end
