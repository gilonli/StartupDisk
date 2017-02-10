//
//  FileDragView.m
//  DragDropDemo
//
//  Created by zhaojw on 15/10/21.
//  Copyright © 2015年 zhaojw. All rights reserved.
//

#import "FileDragView.h"
#import "DSAlert.h"
@implementation FileDragView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib {
    
    [super awakeFromNib];

    if ([self getSystemPath].length) {
        [self.delegate didFinishDragWithFile:[self getSystemPath]];
    }
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        NSInteger numberOfFiles = [files count];
        
        if(numberOfFiles > 0)
        {
            NSString *filePath = [files objectAtIndex:0];
            
            if (![FileDragView checkSystemPath:filePath]) {
                // 提示更新
                [DSAlert alertWithString:@"系统安装包路径有误，请拖拽正确的系统安装包！" name:@"icon3"];
                return NO;
            }
            if(self.delegate){
                [self.delegate didFinishDragWithFile:filePath];
            }
            [[NSUserDefaults standardUserDefaults]setValue:filePath forKey:@"systemPath"];
            return YES;
            
        }

    }
    else{
        NSLog(@"pboard types(%@) not register!",[pboard types]);
    }
    return YES;
}

+ (BOOL)checkSystemPath:(NSString *)systemPath{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:[NSString stringWithFormat:@"%@/Contents/Resources/createinstallmedia",systemPath]];
}

- (NSString *)getSystemPath{
    
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    NSString *systemPath =  [[NSUserDefaults standardUserDefaults]valueForKey:@"systemPath"];
    if(![FileDragView checkSystemPath:systemPath]){
        return nil;
    }
    return systemPath;
}

@end
