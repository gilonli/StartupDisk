//
//  ViewController.m
//  Mac系统启动盘
//
//  Created by Dasen on 2017/1/14.
//  Copyright © 2017年 Adam. All rights reserved.
//

#import "ViewController.h"
#import "DiskComboBox.h"
#import <IOKit/IOKitLib.h>
#import "NSView+Color.h"
#import "FileDragView.h"
#import "DSMakeSystemDisk.h"
#import "DADSDiskTool.h"
#import "ProgressBar+SetStyle.h"
#import <WebKit/WebKit.h>
@import ProgressKit;

typedef NS_ENUM(NSInteger, DiskState) {
    DiskStateSystemNotFound,
    DiskStateNormal,
    DiskStateMaking,
    DiskStateMakeSuccess
};

@interface ViewController () <FileDragViewDelegate,DSTaskdelegate>

@property (weak) IBOutlet DiskComboBox *dsCombox;
@property (weak) IBOutlet NSImageView  *font;
@property (weak) IBOutlet NSTextField  *pathLabel;
@property (weak) IBOutlet FileDragView *fileDragView;

@property (nonatomic, strong)DADSDiskTool   *diskTool;
@property (nonatomic, strong)DSMakeSystemDisk *dsTask;

@property (nonatomic, copy)NSString *systemFilePath;
@property (nonatomic, strong)ProgressBar *processBar;

@property (nonatomic, strong)Spinner *loadingView;

@property (nonatomic, strong)WKWebView *loadingWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self objcLoad];
    [self.view addSubview:self.processBar];
}

- (void)objcLoad{
    [self dsTask];
    self.dsCombox.diskTool       = self.diskTool;
    self.dsCombox.editable       = NO;
    self.fileDragView.delegate   = self;
    self.view.mm_BackgroundColor = [NSColor whiteColor];
    
}

- (IBAction)makeSystem:(NSButton *)sender {
    [self.dsTask makeStartupDiskWithSystemPath:self.systemFilePath disk:self.dsCombox.stringValue];
}

#pragma mark - 代理方法

/// 执行完成命令
- (void)makeSystemDiskEnd:(NSString *)log
{
    [self setSytemFileState:DiskStateMakeSuccess];
    
    self.processBar.progress = 0;
    [self.loadingWebView removeFromSuperview];
    [DSAlert alertWithString:@"启动盘制作完成，可点击使用说明按钮，进行查看使用说明。" name:@"icon5"];
}

/// 拖拽完成
- (void)didFinishDragWithFile:(NSString *)filePath{
    self.systemFilePath = filePath;
    [self setSytemFileState:DiskStateNormal];
}

/// 路径错误
- (void)makeSystemDiskPathError{
    
    [self setSytemFileState:DiskStateSystemNotFound];
}

/// 制作进度
- (void)makeSystemDiskProcess:(CGFloat)process
{
    [self setSytemFileState:DiskStateMaking];
    
    if (!self.loadingView.superview) {
        [self.view addSubview:self.loadingView];
    }
    
    NSString *number = [NSString stringWithFormat:@"%.2f",process];
    self.processBar.progress = number.floatValue;
    if (_processBar.progress <= 0.01) {
        return ;
    }
    [self.loadingView removeFromSuperview];
    if (!self.loadingWebView.superview) {
        [self.view addSubview:self.loadingWebView];
    }
}
- (void)reloadProcess{
    [self.loadingView    removeFromSuperview];
    [self.loadingWebView removeFromSuperview];
    self.processBar.progress = 0;
}

- (void)makeSystemDiskStateNormal
{
    [self reloadProcess];
    [self setSytemFileState:DiskStateNormal];
}
/// 设置文件状态
- (void)setSytemFileState:(DiskState )state{
    
    NSString *imageName;
    NSString *title = @"路径已获取";
    NSTextAlignment alignment = NSTextAlignmentCenter;
    
    switch (state) {
        case DiskStateSystemNotFound:
            imageName = @"提示";
            title     = @"安装包路径未获取";
            alignment = NSTextAlignmentRight;
            self.systemFilePath = @"";
            break;
        case DiskStateNormal:
            imageName = @"路径已获取";
            alignment = NSTextAlignmentCenter;
            break;
        case DiskStateMaking:
            imageName = @"制作中请稍等";
            break;
        case DiskStateMakeSuccess:
            imageName = @"启动盘制作完成";
            [self reloadProcess];
            break;
        default:
            break;
    }
    self.pathLabel.alignment   = alignment;
    [self.font setImage:[NSImage imageNamed:imageName]];
    
    if (self.systemFilePath.length) {
        self.pathLabel.stringValue = [NSString stringWithFormat:@"%@%@",title,self.systemFilePath];
    }else{
        self.pathLabel.stringValue = title;
    }
}

#pragma mark - 懒加载
- (DSMakeSystemDisk *)dsTask
{
    if (!_dsTask) {
        _dsTask = [[DSMakeSystemDisk alloc]initWithDiskTool:self.diskTool];
        _dsTask.delegate = self;
    }
    return _dsTask;
}

- (DADSDiskTool *)diskTool
{
    if (!_diskTool) {
        _diskTool = [[DADSDiskTool alloc]init];
    }
    return _diskTool;
}

- (ProgressBar *)processBar{
    if (!_processBar) {
        CGFloat x = 10;
        CGFloat y = self.view.height - 20;
        _processBar = [[ProgressBar alloc]initWithFrame:CGRectMake(x, y, self.view.width - 20, 10)];
        [_processBar setStyle];
    }
    return _processBar;
}
- (Spinner *)loadingView
{
    if (!_loadingView) {
        CGFloat w = 100;
        CGFloat x = (self.view.width  - w) * 0.5;
        CGFloat y = (self.view.height - w)+10;
        _loadingView = [[Spinner alloc]initWithFrame:CGRectMake(x, y, w, w)];
        _loadingView.animate = YES;
        _loadingView.background = [NSColor clearColor];
        _loadingView.foreground = [NSColor whiteColor];
    }
    return _loadingView;
}
- (WKWebView *)loadingWebView
{
    if (!_loadingWebView) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"itsnottoolate3" ofType:@"gif"];
        _loadingWebView  = [[WKWebView alloc]initWithFrame:CGRectMake(self.view.width-150, 83, 80, 65)];
       [_loadingWebView loadData:[NSData dataWithContentsOfFile:filePath] MIMEType:@"image/gif" characterEncodingName:nil baseURL:nil];
    }
    return _loadingWebView;
}
@end
